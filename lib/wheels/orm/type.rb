module Wheels
  module Orm

    class UnsupportedTypeError < StandardError
      def initialize(type)
        super("#{type} is not supported in this repository")
      end
    end

    class Type

      def self.inherited(target)
        Wheels::Orm::Types[target.name] = Wheels::Orm::Types[target.name.split("::").last] = target
      end

    end
  end
end