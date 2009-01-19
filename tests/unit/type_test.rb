require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class TypeTest < Test::Unit::TestCase

  class TextTypeTest < Wheels::Orm::Type
  end

  def teardown
    types = Wheels::Orm::Types.instance_variable_get(:@types)
    types.delete("TypeTest::TextTypeTest")
    types.delete("TextTypeTest")
  end

  def test_inherited_type_should_register_itself
    assert_descendant_of(Wheels::Orm::Type, Wheels::Orm::Types["TypeTest::TextTypeTest"])
    assert_descendant_of(Wheels::Orm::Type, Wheels::Orm::Types["TextTypeTest"])
  end
end