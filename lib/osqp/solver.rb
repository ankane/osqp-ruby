module OSQP
  class Solver
    def setup(p, q, a, l, u, **settings)
      # settings
      set = create_settings(settings)

      # data
      m, n = shape(a)
      data = FFI::Data.malloc
      data.n = n
      data.m = m
      data.p = csc_matrix(p, upper: true)
      data.q = float_array(q)
      data.a = csc_matrix(a)
      data.l = float_array(l)
      data.u = float_array(u)

      # work
      work = FFI::Workspace.malloc
      check_result FFI.osqp_setup(work.to_ptr.ref, data, set)
      @work = work
    end

    def solve(*args, **settings)
      setup(*args, **settings) if args.any? || settings.any?

      check_result FFI.osqp_solve(@work)

      # solution
      solution = FFI::Solution.new(@work.solution)
      data = FFI::Data.new(@work.data)
      x = read_float_array(solution.x, data.n)
      y = read_float_array(solution.y, data.m)

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
        pri_res: info.pri_res,
        dua_res: info.dua_res,
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

      if x && y
        check_result FFI.osqp_warm_start(@work, float_array(x), float_array(y))
      elsif x
        check_result FFI.osqp_warm_start_x(@work, float_array(x))
      elsif y
        check_result FFI.osqp_warm_start_y(@work, float_array(y))
      else
        raise Error, "Must set x or y"
      end
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
            "Linear system solver loading error"
          when 4
            "Linear system solver initialization error"
          when 5
            "Non-convex problem"
          when 6
            "Memory allocation error"
          when 7
            "Workspace not initialized"
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

    # TODO add support sparse matrices
    def csc_matrix(mtx, upper: false)
      mtx = mtx.to_a

      m, n = shape(mtx)

      cx = []
      ci = []
      cp = []

      # CSC format
      # https://www.gormanalysis.com/blog/sparse-matrix-storage-formats/
      cp << 0
      n.times do |j|
        mtx.each_with_index do |row, i|
          if row[j] != 0 && (!upper || i <= j)
            cx << row[j]
            ci << i
          end
        end
        # cumulative column values
        cp << cx.size
      end

      nnz = cx.size
      cx = float_array(cx)
      ci = int_array(ci)
      cp = int_array(cp)

      FFI.csc_matrix(m, n, nnz, cx, ci, cp)
    end

    def dimensions
      data = FFI::Data.new(@work.data)
      [data.m, data.n]
    end

    def shape(a)
      if defined?(Matrix) && a.is_a?(Matrix)
        [a.row_count, a.column_count]
      elsif defined?(Numo::NArray) && a.is_a?(Numo::NArray)
        a.shape
      else
        [a.size, a.first.size]
      end
    end

    def create_settings(settings)
      set = FFI::Settings.malloc
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
