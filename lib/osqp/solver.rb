module OSQP
  class Solver
    def setup(p, q, a, l, u, **settings)
      # settings
      set = create_settings(settings)

      # ensure bounds within OSQP infinity
      l = l.map { |v| v < -FFI::OSQP_INFTY ? -FFI::OSQP_INFTY : v }
      u = u.map { |v| v > FFI::OSQP_INFTY ? FFI::OSQP_INFTY : v }

      # data
      # do not assign directly to struct to keep refs
      p = csc_matrix(p, upper: true)
      q = float_array(q)
      a = csc_matrix(a)
      l = float_array(l)
      u = float_array(u)

      # work
      work_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE)
      check_result FFI.osqp_setup(work_ptr, matrix_ptr(p), q, matrix_ptr(a), l, u, a.m, a.n, set)
      work = work_ptr.ptr
      work.free = FFI["osqp_cleanup"]
      @work = FFI::Solver.new(work)
    end

    def solve(*args, **settings)
      setup(*args, **settings) if args.any? || settings.any?

      check_result FFI.osqp_solve(@work)

      # solution
      solution = FFI::Solution.new(@work.solution)
      m, n = dimensions
      x = read_float_array(solution.x, n)
      y = read_float_array(solution.y, m)

      # info
      info = FFI::Info.new(@work.info)

      # TODO prim_inf_cert and dual_inf_cert
      {
        x: x,
        y: y,
        iter: info.iter,
        status: read_string(info.status),
        status_val: info.status_val,
        status_polish: info.status_polish,
        obj_val: info.obj_val,
        pri_res: info.prim_res,
        dua_res: info.dual_res,
        setup_time: info.setup_time,
        solve_time: info.solve_time,
        update_time: info.update_time,
        polish_time: info.polish_time,
        run_time: info.run_time,
        rho_estimate: info.rho_estimate,
        rho_updates: info.rho_updates
      }
    end

    def warm_start(x, y)
      # check dimensions
      m, n = dimensions
      raise Error, "Expected x to be size #{n}, got #{x.size}" if x && x.size != n
      raise Error, "Expected y to be size #{m}, got #{y.size}" if y && y.size != m

      check_result FFI.osqp_warm_start(@work, x ? float_array(x) : nil, y ? float_array(y) : nil)
    end

    private

    def check_result(ret)
      if ret != 0
        # keep similar to official messages to make it easier to search online
        # https://osqp.org/docs/interfaces/status_values.html
        message =
          case ret
          when 1
            "Data validation error"
          when 2
            "Settings validation error"
          when 3
            "Linear system solver initialization error"
          when 4
            "Non-convex problem"
          when 5
            "Memory allocation error"
          when 6
            "Workspace not initialized"
          when 7
            "Error loading algebra library"
          when 8
            "Error opening file for writing"
          when 9
            "Error validating given code generation defines"
          when 10
            "Solver data not initialized"
          when 11
            "Function not implemented in current algebra"
          else
            "Error code #{ret}"
          end

        raise Error, message
      end
    end

    def float_array(arr)
      # OSQP float = double
      Fiddle::Pointer[arr.to_a.pack("d*")]
    end

    def int_array(arr)
      # OSQP int = long long
      Fiddle::Pointer[arr.to_a.pack("q*")]
    end

    def read_float_array(ptr, size)
      # OSQP float = double
      ptr[0, size * Fiddle::SIZEOF_DOUBLE].unpack("d*")
    end

    def read_string(char_ptr)
      idx = char_ptr.index { |v| v == 0 }
      char_ptr[0, idx].map(&:chr).join
    end

    def read_int(ptr)
      # OSQP int = long long
      ptr[0, Fiddle::SIZEOF_LONG_LONG].unpack1("q")
    end

    def csc_matrix(mtx, upper: false)
      mtx = Matrix.from_dense(mtx) unless mtx.is_a?(Matrix)

      if upper
        # TODO improve performance
        mtx = mtx.dup
        mtx.m.times do |i|
          mtx.n.times do |j|
            mtx[i, j] = 0 if i > j
          end
        end
      end

      mtx
    end

    def matrix_ptr(mtx)
      csc = mtx.to_csc
      nnz = csc[:value].size
      cx = float_array(csc[:value])
      ci = int_array(csc[:index])
      cp = int_array(csc[:start])

      ptr = FFI.OSQPCscMatrix_new(mtx.m, mtx.n, nnz, cx, ci, cp)
      ptr.free = FFI["OSQPCscMatrix_free"]
      # save refs
      ptr.instance_variable_set(:@osqp_refs, [cx, ci, cp])
      ptr
    end

    def dimensions
      # OSQP int = long long
      m = Fiddle::Pointer.malloc(Fiddle::SIZEOF_LONG_LONG, Fiddle::RUBY_FREE)
      n = Fiddle::Pointer.malloc(Fiddle::SIZEOF_LONG_LONG, Fiddle::RUBY_FREE)
      FFI.osqp_get_dimensions(@work, m, n)
      [read_int(m), read_int(n)]
    end

    def create_settings(settings)
      set = FFI::Settings.malloc(Fiddle::RUBY_FREE)
      FFI.osqp_set_default_settings(set)

      # hack for setting members with []=
      # safer than send("#{k}=", v)
      entity = set.to_ptr
      settings.each do |k, v|
        entity[k.to_s] = settings_value(v)
      end

      set
    end

    # handle booleans
    def settings_value(v)
      case v
      when true
        1
      when false
        0
      else
        v
      end
    end
  end
end
