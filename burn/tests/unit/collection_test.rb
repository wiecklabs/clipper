require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class CollectionTest < Test::Unit::TestCase
  def test_must_receive_array_as_initialization
    assert_raises(ArgumentError) { Clipper::Collection.new("test") }
  end
end