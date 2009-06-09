require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class ValueProxyTest < Test::Unit::TestCase

  ValueProxy = Clipper::Mappings::ValueProxy

  def test_original_value_unset_on_initialize
    value = ValueProxy.new
    assert_nil(value.original_value)

    value = ValueProxy.new(1)
    assert_nil(value.original_value)
  end

  def test_value_is_set_by_initializer
    value = ValueProxy.new(1)
    assert_equal(1, value.get)
  end

  def test_set_bang_updates_original_value
    value = ValueProxy.new(1)
    value.set!(2)

    assert_equal(2, value.original_value)
  end

  def test_dirty_tracking_with_immutable_value
    value = ValueProxy.new(1)
    value.set(2)

    assert(value.dirty?)
  end

  def test_dirty_tracking_with_mutable_value
    value = ValueProxy.new

    val = "ten"
    value.set!(val)

    val.replace("twenty")

    assert_equal("ten", value.original_value)
    assert_equal("twenty", value.get)
    assert(value.dirty?)
  end
end