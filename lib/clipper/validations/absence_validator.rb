module Clipper
  module Validations

    class AbsenceValidator < Validator
      def initialize(field)
        @field = field
      end

      def call(instance, errors)
        unless instance.send(@field).blank?
          errors.append(instance, "%1$s should be absent." % [@field], @field)
        end
      end
    end

  end # module Validations
end # module Clipper