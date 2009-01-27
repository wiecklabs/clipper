require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"


class OrderedSetTest < Test::Unit::TestCase
  def test_ordered_set_first
    set = Java::OrderedSet.new
    set.add "test1"
    set.add "test2"

    assert_equal("test1", set.first)
    assert_equal("test1", set.first)
  end
end