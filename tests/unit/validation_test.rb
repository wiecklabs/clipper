require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"
require 'ostruct'

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
    attr_reader :name, :email
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

  def test_absent_validator
    v = Wheels::Orm::Validations::RequiredValidator.new("name")

    v.call(Person.new("Me"), @errors)
    assert_empty(@errors)

    v.call(Person.new(nil), @errors)
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

    minimum.call(Person.new("Joe"), @errors)
    assert_empty(@errors)

    minimum.call(Person.new("Me"), @errors)
    assert_not_empty(@errors)
  end

  def test_maximum_length_validator
    minimum = Wheels::Orm::Validations::MaximumLengthValidator.new("name", 7)
    
    minimum.call(Person.new("Jackson"), @errors)
    assert_empty(@errors)

    minimum.call(Person.new("Joe"), @errors)
    assert_empty(@errors)

    minimum.call(Person.new("Jackson5"), @errors)
    assert_not_empty(@errors)
  end

  def test_format_validator
    v = Wheels::Orm::Validations::FormatValidator.new("email", /\w+@\w+\.com/)

    v.call(OpenStruct.new(:email => "test@example.com"), @errors)
    assert_empty(@errors)

    v.call(OpenStruct.new(:email => "invalidemailaddress"), @errors)
    assert_not_empty(@errors)
  end

  def test_within_validator_with_range
    v = Wheels::Orm::Validations::WithinValidator.new("age", 21..35)

    v.call(OpenStruct.new(:age => 21), @errors)
    assert_empty(@errors)

    v.call(OpenStruct.new(:age => 35), @errors)
    assert_empty(@errors)

    v.call(OpenStruct.new(:age => 20), @errors)
    assert_not_empty(@errors)

    v.call(OpenStruct.new(:age => 36), @errors)
    assert_not_empty(@errors)
  end

  def test_within_validator_with_array
    v = Wheels::Orm::Validations::WithinValidator.new("gender", %w{M F})

    v.call(OpenStruct.new(:gender => 'M'), @errors)
    assert_empty(@errors)

    v.call(OpenStruct.new(:gender => 'F'), @errors)
    assert_empty(@errors)

    v.call(OpenStruct.new(:gender => 'A'), @errors)
    assert_not_empty(@errors)
  end

  def test_size_validator
    v = Wheels::Orm::Validations::SizeValidator.new("code", 5..8)

    v.call(OpenStruct.new(:code => '12345'), @errors)
    assert_empty(@errors)

    v.call(OpenStruct.new(:code => '1234567'), @errors)
    assert_empty(@errors)

    v.call(OpenStruct.new(:code => '12345678'), @errors)
    assert_empty(@errors)

    v.call(OpenStruct.new(:code => '1234'), @errors)
    assert_not_empty(@errors)

    v.call(OpenStruct.new(:code => '123456789'), @errors)
    assert_not_empty(@errors)
  end

end