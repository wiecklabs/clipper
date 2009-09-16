require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class TypeTest < Test::Unit::TestCase
  def test_raises_exception_if_col_definition_is_not_set
    type = Class.new do
      include Clipper::Repository::Type
    end.new

    assert_raises(Exception) do
      type.col_definition
    end
  end
end
