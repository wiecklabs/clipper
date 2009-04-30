require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class TypeTest < Test::Unit::TestCase

  class TextTypeTest < Beacon::Type
  end

  def teardown
    types = Beacon::Types.instance_variable_get(:@types)
    types.delete("TypeTest::TextTypeTest")
    types.delete("TextTypeTest")
  end

  def test_inherited_type_should_register_itself
    assert_descendant_of(Beacon::Type, Beacon::Types["TypeTest::TextTypeTest"])
    assert_descendant_of(Beacon::Type, Beacon::Types["TextTypeTest"])
  end
end