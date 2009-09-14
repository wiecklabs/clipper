require "pathname"
require Pathname(__FILE__).dirname.parent.parent.parent + "helper"

class HelperTest < Test::Unit::TestCase
  Helper = Clipper::Repositories::Types::Helper
  UnknownTypeError = Clipper::Repositories::Types::Helper::UnknownTypeError

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
    assert(helper.string.is_a?(Types::String))
  end

  def test_initialize_type_with_arguments_provided
    precision = 5
    scale = 2

    float_type = helper.float(precision, scale)

    assert_equal(precision, float_type.precision)
    assert_equal(scale, float_type.scale)
  end

  def test_unknown_type
    assert_raise(UnknownTypeError) do
      helper.unknown(100)
    end
  end

  private
  
  module Types
    class String
    end
    class Float
      attr_reader :precision,
                  :scale

      def initialize(precision, scale)
        @precision, @scale = precision, scale
      end
    end
  end

  def helper
    Helper.new(Types)
  end
end