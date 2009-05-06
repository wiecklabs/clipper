require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"
require 'ostruct'

class ValidationContextTest < Test::Unit::TestCase
  
  def setup
  end

  def teardown
  end
  
  def test_validation_block_executed
    @executed = false
    validation_block = lambda { |check| @executed = true }

    context = Clipper::Validations::Context.new('mapping', "registration", &validation_block)
    context.validate(Class.new.new)

    assert(@executed)
  end

  def test_validation_returns_validation_result
    validation_block = lambda { |check| @executed = true }

    context = Clipper::Validations::Context.new('mapping', "registration", &validation_block)
    result = context.validate(Class.new.new)

    assert_kind_of(Clipper::Validations::ValidationResult, result)
  end

end
