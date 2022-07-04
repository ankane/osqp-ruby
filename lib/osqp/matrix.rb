module OSQP
  class Matrix
    attr_reader :m, :n

    def initialize(m, n)
      @m = m
      @n = n
      @data = {}
    end

    def []=(row_index, column_index, value)
      raise IndexError, "row index out of bounds" if row_index < 0 || row_index >= @m
      raise IndexError, "column index out of bounds" if column_index < 0 || column_index >= @n
      if value == 0
        (@data[column_index] ||= {}).delete(row_index)
      else
        (@data[column_index] ||= {})[row_index] = value
      end
    end

    def to_ptr
      cx = []
      ci = []
      cp = []

      # CSC format
      # https://www.gormanalysis.com/blog/sparse-matrix-storage-formats/
      cp << 0
      n.times do |j|
        (@data[j] || {}).sort_by { |k, v| k }.each do |k, v|
          cx << v
          ci << k
        end
        # cumulative column values
        cp << cx.size
      end

      nnz = cx.size
      cx = Utils.float_array(cx)
      ci = Utils.int_array(ci)
      cp = Utils.int_array(cp)

      ptr = FFI.csc_matrix(m, n, nnz, cx, ci, cp)
      # save refs
      ptr.instance_variable_set(:@osqp_refs, [cx, ci, cp])
      ptr
    end
  end
end
