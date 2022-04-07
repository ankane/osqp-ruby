module OSQP
  module FFI
    extend Fiddle::Importer

    libs = Array(OSQP.ffi_lib).dup
    begin
      dlload Fiddle.dlopen(libs.shift)
    rescue Fiddle::DLError => e
      retry if libs.any?
      raise e
    end

    typealias "c_float", "double"
    typealias "c_int", "long long"
    typealias "enum", "int"

    Data = struct [
      "c_int n",
      "c_int m",
      "csc *p",
      "csc *a",
      "c_float *q",
      "c_float *l",
      "c_float *u"
    ]

    Settings = struct [
      "c_float rho",
      "c_float sigma",
      "c_int scaling",
      "c_int adaptive_rho",
      "c_int adaptive_rho_interval",
      "c_float adaptive_rho_tolerance",
      "c_float adaptive_rho_fraction",
      "c_int max_iter",
      "c_float eps_abs",
      "c_float eps_rel",
      "c_float eps_prim_inf",
      "c_float eps_dual_inf",
      "c_float alpha",
      "enum linsys_solver_type linsys_solver",
      "c_float delta",
      "c_int polish",
      "c_int polish_refine_iter",
      "c_int verbose",
      "c_int scaled_termination",
      "c_int check_termination",
      "c_int warm_start",
      "c_float time_limit"
    ]

    Info = struct [
      "c_int iter",
      "char status[32]",
      "c_int status_val",
      "c_int status_polish",
      "c_float obj_val",
      "c_float pri_res",
      "c_float dua_res",
      "c_float setup_time",
      "c_float solve_time",
      "c_float update_time",
      "c_float polish_time",
      "c_float run_time",
      "c_int   rho_updates",
      "c_float rho_estimate"
    ]

    Solution = struct [
      "c_float *x",
      "c_float *y"
    ]

    Workspace = struct [
      "OSQPData *data",
      "LinSysSolver *linsys_solver",
      "OSQPPolish *pol",
      "c_float *rho_vec",
      "c_float *rho_inv_vec",
      "c_int *constr_type",
      "c_float *x",
      "c_float *y",
      "c_float *z",
      "c_float *xz_tilde",
      "c_float *x_prev",
      "c_float *z_prev",
      "c_float *Ax",
      "c_float *Px",
      "c_float *Aty",
      "c_float *delta_y",
      "c_float *Atdelta_y",
      "c_float *delta_x",
      "c_float *Pdelta_x",
      "c_float *Adelta_x",
      "c_float *D_temp",
      "c_float *D_temp_A",
      "c_float *E_temp",
      "OSQPSettings *settings",
      "OSQPScaling  *scaling",
      "OSQPSolution *solution",
      "OSQPInfo *info",
      "OSQPTimer *timer",
      "c_int first_run",
      "c_int clear_update_time",
      "c_int rho_update_from_solve",
      "c_int summary_printed"
    ]

    # cs.h
    extern "csc* csc_matrix(c_int m, c_int n, c_int nzmax, c_float *x, c_int *i, c_int *p)"

    # osqp.h
    extern "void osqp_set_default_settings(OSQPSettings *settings)"
    extern "c_int osqp_setup(OSQPWorkspace** workp, OSQPData* data, OSQPSettings* settings)"
    extern "c_int osqp_solve(OSQPWorkspace *work)"
    extern "c_int osqp_cleanup(OSQPWorkspace *work)"
    extern "c_int osqp_update_lin_cost(OSQPWorkspace *work, c_float *q_new)"
    extern "c_int osqp_update_bounds(OSQPWorkspace *work, c_float *l_new, c_float *u_new)"
    extern "c_int osqp_update_lower_bound(OSQPWorkspace *work, c_float *l_new)"
    extern "c_int osqp_update_upper_bound(OSQPWorkspace *work, c_float *u_new)"
    extern "c_int osqp_warm_start(OSQPWorkspace *work, c_float *x, c_float *y)"
    extern "c_int osqp_warm_start_x(OSQPWorkspace *work, c_float *x)"
    extern "c_int osqp_warm_start_y(OSQPWorkspace *work, c_float *y)"
    extern "c_int osqp_update_P(OSQPWorkspace *work, c_float *Px_new, c_int *Px_new_idx, c_int P_new_n)"
    extern "c_int osqp_update_A(OSQPWorkspace *work, c_float *Ax_new, c_int *Ax_new_idx, c_int A_new_n)"
    extern "c_int osqp_update_P_A(OSQPWorkspace *work, c_float *Px_new, c_int *Px_new_idx, c_int P_new_n, c_float *Ax_new, c_int *Ax_new_idx, c_int A_new_n)"
    extern "c_int osqp_update_rho(OSQPWorkspace *work, c_float rho_new)"
    extern "c_int osqp_update_max_iter(OSQPWorkspace *work, c_int max_iter_new)"
    extern "c_int osqp_update_eps_abs(OSQPWorkspace *work, c_float eps_abs_new)"
    extern "c_int osqp_update_eps_rel(OSQPWorkspace *work, c_float eps_rel_new)"
    extern "c_int osqp_update_eps_prim_inf(OSQPWorkspace *work, c_float eps_prim_inf_new)"
    extern "c_int osqp_update_eps_dual_inf(OSQPWorkspace *work, c_float eps_dual_inf_new)"
    extern "c_int osqp_update_alpha(OSQPWorkspace *work, c_float alpha_new)"
    extern "c_int osqp_update_warm_start(OSQPWorkspace *work, c_int warm_start_new)"
    extern "c_int osqp_update_scaled_termination(OSQPWorkspace *work, c_int scaled_termination_new)"
    extern "c_int osqp_update_check_termination(OSQPWorkspace *work, c_int check_termination_new)"
    extern "c_int osqp_update_delta(OSQPWorkspace *work, c_float delta_new)"
    extern "c_int osqp_update_polish(OSQPWorkspace *work, c_int polish_new)"
    extern "c_int osqp_update_polish_refine_iter(OSQPWorkspace *work, c_int polish_refine_iter_new)"
    extern "c_int osqp_update_verbose(OSQPWorkspace *work, c_int verbose_new)"
    extern "c_int osqp_update_time_limit(OSQPWorkspace *work, c_float time_limit_new)"

    # util.h
    extern "const char* osqp_version(void)"
  end
end
