module Wheels
  module Orm
    module Validations

      class ConstraintEvaluator

        attr_reader :errors

        def initialize(instance)
          @instance = instance
          @errors = Wheels::Orm::Validations::ValidationErrors.new
        end

        def absent(field)
          return if block_given? && !yield(@instance)
          AbsenceValidator.new(field).call(@instance, @errors)
        end

        def within(field, set)
          return if block_given? && !yield(@instance)
          WithinValidator.new(field, set).call(@instance, @errors)
        end

        def acceptance(field)
          return if block_given? && !yield(@instance)
          AcceptanceValidator.new(field).call(@instance, @errors)
        end

        def format(field, format)
          return if block_given? && !yield(@instance)
          FormatValidator.new(field, format).call(@instance, @errors)
        end

        def maximum(field, length)
          return if block_given? && !yield(@instance)
          MaximumLengthValidator.new(field, foramt).call(@instance, @errors)
        end

        def minimum(field, length)
          return if block_given? && !yield(@instance)
          MinimumLengthValidator.new(field, foramt).call(@instance, @errors)
        end

        def required(field)
          return if block_given? && !yield(@instance)
          RequiredValidator.new(field).call(@instance, @errors)
        end

        def size(field, size)
          return if block_given? && !yield(@instance)
          SizeValidator.new(field).call(@instance, @errors)
        end

        def within(field, set)
          return if block_given? && !yield(@instance)
          WithinValidator.new(field, set).call(@instance, @errors)
        end
      end

      class Context

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
          @validation_block.call(evaluator).errors
        end

      end
    end
  end # module Orm
end # module Wheels