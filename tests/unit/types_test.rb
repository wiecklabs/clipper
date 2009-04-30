require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class TypesTest < Test::Unit::TestCase

  def setup
  end

  # ===============
  # String
  # ===============

  def test_string_initializer
    assert_raise(ArgumentError) { Beacon::Types::String.new() }
    assert_raise(ArgumentError) { Beacon::Types::String.new('abc') }
    assert_raise(ArgumentError) { Beacon::Types::String.new('123') }
    assert_raise(ArgumentError) { Beacon::Types::String.new(23.23) }

    assert_nothing_raised { Beacon::Types::String.new(255) }
  end

  def test_string_convenience_method
    assert_respond_to(Beacon::Types, :String)
    assert_nothing_raised { Beacon::Types::String(255) }
  end

  def test_string_attributes
    type = Beacon::Types::String(255)

    assert_respond_to(type, :size)
    assert_equal(255, type.size)
  end

  # ===============
  # Float
  # ===============

  def test_float_initializer
    assert_raise(ArgumentError) { Beacon::Types::Float.new() }
    assert_raise(ArgumentError) { Beacon::Types::Float.new('abc', '123') }
    assert_raise(ArgumentError) { Beacon::Types::Float.new(2, '123') }
    assert_raise(ArgumentError) { Beacon::Types::Float.new('123', 2) }
    assert_raise(ArgumentError) { Beacon::Types::Float.new(23.23, 123.2) }

    assert_nothing_raised { Beacon::Types::Float.new(7, 2) }
  end

  def test_float_convenience_method
    assert_respond_to(Beacon::Types, :Float)
    assert_nothing_raised { Beacon::Types::Float.new(7, 2) }
  end

  def test_float_attributes
    type = Beacon::Types::Float(7, 2)

    assert_respond_to(type, :scale)
    assert_respond_to(type, :precision)

    assert_equal(7, type.scale)
    assert_equal(2, type.precision)
  end

end
