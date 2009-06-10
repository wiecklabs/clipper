module Clipper
  class Mappings
    class ValueProxy

      attr_accessor :original_value, :value, :field

      def initialize(field = nil, val = nil)
        @field = field
        @value = val
      end

      def inspect
        "<Value original_value=#{@original_value.inspect} value=#{get.inspect}>"
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
        @original_value != get
      end

      def set_original_value!
        @original_value = get.dup rescue get
      end

    end
  end
end