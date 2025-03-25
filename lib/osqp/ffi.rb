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

    typealias "OSQPFloat", "double"
    typealias "OSQPInt", "long long"
    typealias "enum", "int"

    OSQP_INFTY = 1e30

    Settings = struct [
      # linear algebra settings
      "OSQPInt device",
      "enum osqp_linsys_solver_type linsys_solver",

      # control settings
      "OSQPInt allocate_solution",
      "OSQPInt verbose",
      "OSQPInt profiler_level",
      "OSQPInt warm_starting",
      "OSQPInt scaling",
      "OSQPInt polishing",

      # ADMM parameters
      "OSQPFloat rho",
      "OSQPInt rho_is_vec",
      "OSQPFloat sigma",
      "OSQPFloat alpha",

      # CG settings
      "OSQPInt cg_max_iter",
      "OSQPInt cg_tol_reduction",
      "OSQPFloat cg_tol_fraction",
      "enum osqp_precond_type cg_precond",

      # adaptive rho logic
      "OSQPInt adaptive_rho",
      "OSQPInt adaptive_rho_interval",
      "OSQPFloat adaptive_rho_fraction",
      "OSQPFloat adaptive_rho_tolerance",

      # termination parameters
      "OSQPInt   max_iter",
      "OSQPFloat eps_abs",
      "OSQPFloat eps_rel",
      "OSQPFloat eps_prim_inf",
      "OSQPFloat eps_dual_inf",
      "OSQPInt scaled_termination",
      "OSQPInt check_termination",
      "OSQPInt check_dualgap",
      "OSQPFloat time_limit",

      # polishing parameters
      "OSQPFloat delta",
      "OSQPInt polish_refine_iter"
    ]

    Info = struct [
      # solver status
      "char status[32]",
      "OSQPInt status_val",
      "OSQPInt status_polish",

      # solution quality
      "OSQPFloat obj_val",
      "OSQPFloat dual_obj_val",
      "OSQPFloat prim_res",
      "OSQPFloat dual_res",
      "OSQPFloat duality_gap",

      # algorithm information
      "OSQPInt iter",
      "OSQPInt rho_updates",
      "OSQPFloat rho_estimate",

      # timing information
      "OSQPFloat setup_time",
      "OSQPFloat solve_time",
      "OSQPFloat update_time",
      "OSQPFloat polish_time",
      "OSQPFloat run_time",

      # convergence information
      "OSQPFloat primdual_int",
      "OSQPFloat rel_kkt_error"
    ]

    Solution = struct [
      "OSQPFloat *x",
      "OSQPFloat *y",
      "OSQPFloat *prim_inf_cert",
      "OSQPFloat *dual_inf_cert"
    ]

    Solver = struct [
      "OSQPSettings* settings",
      "OSQPSolution* solution",
      "OSQPInfo* info",
      "OSQPWorkspace* work"
    ]

    # https://github.com/osqp/osqp/blob/master/include/public/osqp_api_functions.h

    # CSC matrix manipulation
    extern "OSQPCscMatrix* OSQPCscMatrix_new(OSQPInt m, OSQPInt n, OSQPInt nzmax, OSQPFloat* x, OSQPInt* i, OSQPInt* p)"

    # main solver API
    extern "const char* osqp_version(void)"
    extern "const char* osqp_error_message(OSQPInt error_flag)"
    extern "void osqp_get_dimensions(OSQPSolver* solver, OSQPInt* m, OSQPInt* n)"
    extern "OSQPInt osqp_setup(OSQPSolver** solverp, OSQPCscMatrix* P, OSQPFloat* q, OSQPCscMatrix* A, OSQPFloat* l, OSQPFloat* u, OSQPInt m, OSQPInt n, OSQPSettings* settings)"
    extern "OSQPInt osqp_solve(OSQPSolver* solver)"
    extern "OSQPInt osqp_cleanup(OSQPSolver* solver)"

    # sublevel API
    extern "OSQPInt osqp_warm_start(OSQPSolver* solver, OSQPFloat* x, OSQPFloat* y)"
    extern "void osqp_cold_start(OSQPSolver* solver)"

    # settings
    extern "void osqp_set_default_settings(OSQPSettings* settings)"
  end
end
