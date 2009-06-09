module Clipper
  class Mappings
    class ValueProxy

      attr_accessor :original_value, :value

      def initialize(val = nil)
        @value = val
      end

      def inspect
        "<Value original_value=#{@original_value.inspect} value=#{@value.inspect}>"
      end

      def set(val)
        @value = val
      end

      def set!(val)
        set(val)
        set_original_value!
      end

      def get
        @value
      end

      def dirty?
        @original_value != @value
      end

      def set_original_value!
        @original_value = @value.dup rescue @value
      end

    end
  end
end