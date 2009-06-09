module Clipper
  class Mappings
    class ValueProxy

      def initialize(val = nil)
        @original_value = val.dup rescue val
        @value = val
      end

      def inspect
        "<Value original_value=#{@original_value.inspect} value=#{@value.inspect}>"
      end

      def set(val)
        @value = val
      end

      def get
        @value
      end

      def dirty?
        @original_value != self.read
      end

      def reset!
        @original_value = @value.dup rescue @value
      end

    end
  end
end