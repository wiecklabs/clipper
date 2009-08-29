module Clipper
  class Mapping
    class Field

      attr_accessor :type, :accessor, :name, :mapping

      def initialize(type, accessor, default_name, mapping)
        raise ArgumentError.new("+type+ must be an instance") if type.is_a?(Class)
        raise ArgumentError.new("+type+ must include Clipper::Repository::Type") unless Clipper::Repository::Type > type.class
        raise ArgumentError.new("+accessor+ must be a Clipper::Accessors::TypedAccessor") unless accessor.is_a?(Clipper::Accessors::TypedAccessor)
        raise ArgumentError.new('+mapping+ must be a Clipper::Mapping') unless mapping.is_a?(Clipper::Mapping)

        @type = type
        @accessor = accessor
        @name = type.name || default_name
        @mapping = mapping
      end

    end
  end
end