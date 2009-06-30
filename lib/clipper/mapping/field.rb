module Clipper
  class Mapping
    class Field

      attr_accessor :type, :accessor, :name

      def initialize(type, accessor, default_name)
        raise ArgumentError.new("+type+ must be an instance") if type.is_a?(Class)
        raise ArgumentError.new("+type+ must include Clipper::Repository::Type") unless Clipper::Repository::Type > type.class
        raise ArgumentError.new("+accessor+ must be a Clipper::Accessors::TypedAccessor") unless accessor.is_a?(Clipper::Accessors::TypedAccessor)

        @type = type
        @accessor = accessor
        @name = type.name || default_name
      end

    end
  end
end