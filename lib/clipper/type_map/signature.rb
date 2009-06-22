module Clipper
  class TypeMap
    class Signature

      # A Clipper::TypeMap::Signature is used to convert to and from
      # values matching the types defined for it using the procedures
      # passed to the +typecast_left_procedure+ and +typecast_right_procedure+ arguments.
      def initialize(attribute_types, repository_types, typecast_left_procedure, typecast_right_procedure)

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

        unless typecast_left_procedure.respond_to?(:call)
          raise ArgumentError.new("#{self.class}:typecast_left_procedure must respond to :call")
        end
        @typecast_left_procedure = typecast_left_procedure

        unless typecast_right_procedure.respond_to?(:call)
          raise ArgumentError.new("#{self.class}:typecast_right_procedure must respond to :call")
        end
        @typecast_right_procedure = typecast_right_procedure
      end

      def match?(attribute_types, repository_types)
        attribute_types == @attribute_types && repository_types == @repository_types
      end

      def typecast_left(*args)
        matching_types = true
        @repository_types.each_with_index do |type, i|
          unless args[i] == nil || args[i].is_a?(type)
            matching_types = false
            break
          end
        end

        unless matching_types
          raise ArgumentError.new("Expected args to be instances of #{@repository_types.inspect} but was #{args.inspect}.")
        end

        @typecast_left_procedure.call(*args)
      end

      def typecast_right(*args)
        matching_types = true
        @attribute_types.each_with_index do |type, i|
          unless args[i] == nil || args[i].is_a?(type)
            matching_types = false
            break
          end
        end

        unless matching_types
          raise ArgumentError.new("Expected args to be instances of #{@attribute_types.inspect} but was #{args.inspect}.")
        end
        @typecast_right_procedure.call(*args)
      end
    end # class Signature
  end # class TypeMap
end # module Clipper