module Wheels
  module Orm
    module Types

      @types = {}

      def self.[](name)
        @types[name]
      end

      def self.[]=(name, value)
        @types[name] = value
      end

      class String < Type
      end

      class Integer < Type
      end

      class Serial < Type
      end

      class Float < Type
      end

    end
  end
end