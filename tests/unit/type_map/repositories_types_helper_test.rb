require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class RepositoriesTypesHelperTest < Test::Unit::TestCase
  Helper = Clipper::TypeMap::RepositoriesTypesHelper
  UnknownTypeError = Clipper::UnknownTypeError

  def test_initialize_with_proper_arguments
    assert_nothing_raised do
      Helper.new(Types)
    end
  end

  def test_initialize_with_improper_arguments
    assert_raise(ArgumentError) do
      Helper.new(nil)
    end

    assert_raise(ArgumentError) do
      Helper.new(Class.new.new)
    end
  end

  def test_type
    assert(helper.string == Types::String)
  end

  def test_unknown_type
    assert_raise(UnknownTypeError) do
      helper.unknown
    end
  end

  private

  module Types
    class String
    end
    class Float
    end
  end

  def helper
    Helper.new(Types)
  end
end