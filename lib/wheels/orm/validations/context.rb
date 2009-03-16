module Wheels
  module Orm
    module Validations

      class ConstraintEvaluator

        attr_reader :validation_result

        def initialize(instance)
          @instance = instance
          @validation_result = Wheels::Orm::Validations::ValidationResult.new
        end

        def absent(field)
          return if block_given? && !yield(@instance)
          AbsenceValidator.new(field).call(@instance, @validation_result)
        end

        def within(field, set)
          return if block_given? && !yield(@instance)
          WithinValidator.new(field, set).call(@instance, @validation_result)
        end

        def acceptance(field)
          return if block_given? && !yield(@instance)
          AcceptanceValidator.new(field).call(@instance, @validation_result)
        end

        def format(field, format)
          return if block_given? && !yield(@instance)
          FormatValidator.new(field, format).call(@instance, @validation_result)
        end

        def maximum(field, length)
          return if block_given? && !yield(@instance)
          MaximumLengthValidator.new(field, foramt).call(@instance, @validation_result)
        end

        def minimum(field, length)
          return if block_given? && !yield(@instance)
          MinimumLengthValidator.new(field, foramt).call(@instance, @validation_result)
        end

        def required(field)
          return if block_given? && !yield(@instance)
          RequiredValidator.new(field).call(@instance, @validation_result)
        end

        def size(field, size)
          return if block_given? && !yield(@instance)
          SizeValidator.new(field).call(@instance, @validation_result)
        end

        def within(field, set)
          return if block_given? && !yield(@instance)
          WithinValidator.new(field, set).call(@instance, @validation_result)
        end
      end

      class Context

        # TODO: Re-do the way validations are executed.  The block should be executed
        # upon creation of the context
        def initialize(mapping, name, &block)
          @mapping = mapping
          @name = name
          @validation_block = block
        end

        def mapping
          @mapping
        end

        def name
          @name
        end

        def eql?(other)
          other.is_a?(Context) && @mapping == other.mapping && @name == other.name
        end

        def hash
          @hash ||= [@mapping, @name].hash
        end

        def validate(instance)
          evaluator = ConstraintEvaluator.new(instance)
          @validation_block.call(evaluator)
          evaluator.validation_result
        end

      end
    end
  end # module Orm
end # module Wheels