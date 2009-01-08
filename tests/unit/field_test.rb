require "helper"

class FieldTest < Test::Unit::TestCase
  # def setup
  # end

  # def teardown
  # end

  def test_field_requires_two_arguments
    assert_equal(Wheels::Orm::Mappings::Field.instance_method("initialize").arity, 2)
  end
  
end