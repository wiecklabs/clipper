module Clipper
  module Validations

    class EqualityValidator < Validator
      def initialize(field1, field2)
        @field1 = field1
        @field2 = field2
      end

      def call(instance, errors)
        unless instance.send(@field1) == instance.send(@field2)
          errors.append(instance, "%1$s should be equal to %1$s." % [@field1, @field2], @field1)
        end
      end
    end

  end # module Validations
end # module Clipper