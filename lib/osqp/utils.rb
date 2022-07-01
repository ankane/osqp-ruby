module OSQP
  module Utils
    class << self
      def float_array(arr)
        # OSQP float = double
        Fiddle::Pointer[arr.to_a.pack("d*")]
      end

      def int_array(arr)
        # OSQP int = long long
        Fiddle::Pointer[arr.to_a.pack("q*")]
      end
    end
  end
end
