require 'date'

module Clipper
  module Types
    class Serial
    end

    class Boolean
    end

#    @types = {}
#
#    def self.[](name)
#      @types[name]
#    end
#
#    def self.[]=(name, value)
#      @types[name] = value
#    end
#
#    class String < Type
#
#      attr_reader :size
#
#      def initialize(size)
#        raise ArgumentError.new("String#new expects an integer size as the first argument") unless size.is_a?(Fixnum)
#        @size = size
#      end
#
#    end
#
#    def self.String(size)
#      String.new(size)
#    end
#
#    class Text < Type
#    end
#
#    class Integer < Type
#    end
#
#    class Serial < Type
#    end
#
#    class Float < Type
#
#      attr_reader :scale, :precision
#
#      def initialize(scale, precision)
#        raise ArgumentError.new("Float#new expects an integer scale as the first argument") unless scale.is_a?(Fixnum)
#        raise ArgumentError.new("Float#new expects an integer precision as the second argument") unless precision.is_a?(Fixnum)
#
#        @scale, @precision = scale, precision
#      end
#
#    end
#
#    def self.Float(scale, precision)
#      Float.new(scale, precision)
#    end
#
#    class Time < Type
#    end
#
#    class Date < Type
#    end
#
#    class DateTime < Type
#    end
#
#    class Boolean < Type
#    end
  end
end