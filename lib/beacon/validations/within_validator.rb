module Beacon
  module Validations

    class WithinValidator
      def initialize(field, set)
        @field = field
        @set = set
      end

      def call(instance, errors)
        unless @set.include?(instance.send(@field))
          message = if @set.is_a?(Array)
            "%1$s must be one of: #{@set[0..-2].join(', ')}, or #{@set.last}"
          elsif @set.is_a?(Range)
            "%1$s must be between #{@set.min} and #{@set.max}"
          else
            "%1$s is not within the valid range"
          end

          errors.append(instance, message % [@field], @field)
        end
      end
    end

  end # module Validations
end # module Beacon