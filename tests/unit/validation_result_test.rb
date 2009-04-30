require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class ValidationResultTest < Test::Unit::TestCase
  
  def setup
  end

  def teardown
  end

  def test_initializer
    assert_nothing_raised { Beacon::Validations::ValidationResult.new }
  end

  def test_validation_result_is_valid
    result = Beacon::Validations::ValidationResult.new
    assert_equal(true, result.valid?)
    assert_equal(false, result.invalid?)
  end

  def test_valiation_result_is_invalid
    result = Beacon::Validations::ValidationResult.new

    result.append(Object.new, "Name is required", :name)

    assert_equal(false, result.valid?)
    assert_equal(true, result.invalid?)
  end

end