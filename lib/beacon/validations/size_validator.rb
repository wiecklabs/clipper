module Beacon
  module Validations
    
    class SizeValidator < Validator
      def initialize(field, size)
        @field = field
        @size = size
      end

      def call(instance, errors)
        if @size.is_a?(Range)
          unless @size.include?(instance.send(@field).size)
            errors.append(instance, "%1$s must be between %2$s and %3$s charcters long" % [@field, @size.min, @size.max], @field)
          end
        elsif @size.is_a(Fixnum)
          unless @size == instance.send(@field).size
            errors.append(instance, "%1$s must be exactly %2$s charcters long" % [@field, @size], @field)
          end
        else
          raise NotImplementedError.new("Cannot validate size of %1$s with #{@size.inspect}" % [@field])
        end
      end
    end

  end # module Validations
end # module Beacon