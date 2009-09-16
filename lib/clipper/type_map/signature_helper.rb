module Clipper
  class TypeMap
    class SignatureHelper
      def from(attribute_types)
        @attribute_types = attribute_types
      end

      def to(repository_types)
        @repository_types = repository_types
      end

      def typecast_left(typecast_left_procedure)
        @typecast_left_procedure = typecast_left_procedure
      end

      def typecast_right(typecast_right_procedure)
        @typecast_right_procedure = typecast_right_procedure
      end

      def create_signature
        Clipper::TypeMap::Signature.new(
          @attribute_types,
          @repository_types,
          @typecast_left_procedure,
          @typecast_right_procedure
        )
      end
    end # class SignatureHelper
  end # class TypeMap
end # module Clipper