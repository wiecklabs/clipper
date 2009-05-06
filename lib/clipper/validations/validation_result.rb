module Clipper
  module Validations

    class ValidationResult

      def initialize
        @errors = Set.new
      end

      def errors
        @errors
      end

      def append(instance, message, *fields)
        error = ValidationError.new(instance, message, *fields)
        errors << error
        error
      end

      def empty?
        errors.empty?
      end

      def valid?
        empty?
      end

      def invalid?
        !valid?
      end
    end # class ValidationResult

  end # module Validations
end # module Clipper