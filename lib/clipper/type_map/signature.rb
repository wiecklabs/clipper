module Clipper
  class TypeMap
    class Signature

      # A Clipper::TypeMap::Signature is used to convert to and from
      # values matching the types defined for it using the procedures
      # passed to the +from_procedure+ and +to_procedure+ arguments.
      def initialize(attribute_types, repository_types, from_procedure, to_procedure)

        unless attribute_types.is_a?(Array) && attribute_types.all? { |type| type.is_a?(Class) }
          raise ArgumentError.new(
            "#{self.class}:attribute_types should be an Array of Classes but was #{attribute_types.inspect}"
          )
        end
        @attribute_types = attribute_types

        unless repository_types.is_a?(Array) && repository_types.all? { |type| type.is_a?(Class) }
          raise ArgumentError.new(
            "#{self.class}:repository_types should be an Array of Classes was a #{repository_types.inspect}"
          )
        end
        @repository_types = repository_types

        unless from_procedure.respond_to?(:call)
          raise ArgumentError.new("#{self.class}:from_procedure must respond to :call")
        end
        @from_procedure = from_procedure

        unless to_procedure.respond_to?(:call)
          raise ArgumentError.new("#{self.class}:to_procedure must respond to :call")
        end
        @to_procedure = to_procedure
      end
    end
  end
end