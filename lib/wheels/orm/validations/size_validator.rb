module Wheels
  module Orm
    module Validations
      
      class SizeValidator
        def initialize(field, size)
          @field = field
          @size = size
        end

        def call(instance, errors)
          if @size.is_a?(Range)
            unless @size.include?(instance.send(@field).size)
              errors.append(instance, "%1$s must be between #{@size.min} and #{@size.max} charcters long" % [@field], @field)
            end
          elsif @size.is_a(Fixnum)
            unless @size == instance.send(@field).size
              errors.append(instance, "%1$s must be exactly #{@size} charcters long" % [@field], @field)
            end
          else
            raise NotImplementedError.new("Cannot validate size of %1$s with #{@size.inspect}" % [@field])
          end
        end
      end

    end # module Validations
  end # module Orm
end # module Wheels