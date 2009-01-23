require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class ValidationTest < Test::Unit::TestCase

  module Wheels
    module Orm
      module Validations
        
        class ValidationError
          attr_reader :instance, :message, :fields
          
          def initialize(instance, message, *fields)
            @instance = instance
            @message = message
            @fields = fields
          end
        end
        
        class MinimumLengthValidator
          def initialize(field, length)
            @field = field
            @length = length
          end
          
          def call(instance, errors)
            if instance.send(@field).length < @length
              errors.append(instance, "%1$s is too short! Must be longer than %2$s characters." % [@field, @length], "name")
            end
          end
        end
        
        class ValidationErrors
          def initialize
            @errors = Set.new
          end
          
          def append(instance, message, *fields)
            error = ValidationError.new(instance, message, *fields)
            @errors << error
            error
          end
        end
        
      end # module Validations
    end # module Orm
  end # module Wheels
  
  def test_validations_return_nil_or_a_validation_error
    minimum = Wheels::Orm::Validations::MinimumLengthValidator.new("name", 3)
    
    person = Class.new do
      attr_reader :name
      def initialize(name)
        @name = name
      end
    end
    
    errors = Wheels::Orm::Validations::ValidationErrors.new
    
    assert_nil(minimum.call(person.new("Jackson"), errors))
    assert_not_nil(minimum.call(person.new("Me"), errors))
  end
end