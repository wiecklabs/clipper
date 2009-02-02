require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class ValidationTest < Test::Unit::TestCase
  
  # Validators:
  # Absent
  # Acceptance
  # Confirmation => equal
  # Format
  # Custom
  # Length
  # isNumeric
  # Required
  # Unique
  # Range
  # WithinSet
  
  class Person
    attr_reader :name
    def initialize(name)
      @name = name
    end
  end
  
  def setup
    @errors = Wheels::Orm::Validations::ValidationErrors.new
  end
  
  def test_absent_validator
    minimum = Wheels::Orm::Validations::AbsenceValidator.new("name")  
    
    minimum.call(Person.new(nil), @errors)
    assert_empty(@errors)
    
    minimum.call(Person.new("Me"), @errors)
    assert_not_empty(@errors)
  end
  
  def test_acceptance_validator
    minimum = Wheels::Orm::Validations::AcceptanceValidator.new("name")  
    
    minimum.call(Person.new("Jackson"), @errors)
    assert_empty(@errors)
    
    minimum.call(Person.new(nil), @errors)
    assert_not_empty(@errors)
  end
  
  def test_minimum_length_validator
    minimum = Wheels::Orm::Validations::MinimumLengthValidator.new("name", 3)  
    
    minimum.call(Person.new("Jackson"), @errors)
    assert_empty(@errors)
    
    minimum.call(Person.new("Me"), @errors)
    assert_not_empty(@errors)
  end
  
end