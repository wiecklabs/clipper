module Clipper
  module Validations

    class ValidationFactory

      def self.create(validation_class, *args, &precondition_block)
        validation = validation_class.new(*args)
        validation.precondition_block = precondition_block
        validation
      end

    end

    class ConstraintEvaluator

      def initialize
        @validations = []
      end

      def run(instance)
        validation_result = Clipper::Validations::ValidationResult.new

        @validations.each do |validation|
          validation.call(instance, validation_result) if validation.should_run?(instance)
        end

        validation_result
      end

      def absent(field, &block)
        append_validation(ValidationFactory.create(AbsenceValidator, field, &block))
      end

      def within(field, set, &block)
        append_validation(ValidationFactory.create(WithinValidator, field, set, &block))
      end

      def acceptance(field, &block)
        append_validation(ValidationFactory.create(AcceptanceValidator, field, &block))
      end

      def format(field, format, &block)
        append_validation(ValidationFactory.create(FormatValidator, field, format, &block))
      end

      def maximum(field, length, &block)
        append_validation(ValidationFactory.create(MaximumLengthValidator, field, length, &block))
      end

      def minimum(field, length, &block)
        append_validation(ValidationFactory.create(MinimumLengthValidator, field, length, &block))
      end

      def required(field, &block)
        append_validation(ValidationFactory.create(RequiredValidator, field, &block))
      end

      def size(field, size, &block)
        append_validation(ValidationFactory.create(SizeValidator, field, size, &block))
      end

      def within(field, set, &block)
        append_validation(ValidationFactory.create(WithinValidator, field, set, &block))
      end

      def equal(field1, field2, &block)
        append_validation(ValidationFactory.create(EqualityValidator, field1, field2, &block))
      end

      private

      def append_validation(validator)
        @validations << validator
      end
    end

    class Context

      def initialize(target, name)
        @target = target
        @name = name

        @evaluator = ConstraintEvaluator.new
        yield(@evaluator) if block_given?
      end

      def target
        @target
      end

      def name
        @name
      end

      def eql?(other)
        other.is_a?(Context) && @target == other.target && @name == other.name
      end

      def hash
        @hash ||= [@target, @name].hash
      end

      def validate(instance)
        @evaluator.run(instance)
      end

    end
  end
end # module Clipper