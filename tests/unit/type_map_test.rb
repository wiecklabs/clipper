require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class TypeMapTest < Test::Unit::TestCase

  def setup
    typecast_left_procedure = lambda { |age| age.to_s }
    typecast_right_procedure = lambda { |age| age.to_i }

    @signature = Clipper::TypeMap::Signature.new(
      [String],
      [Integer],
      typecast_left_procedure,
      typecast_right_procedure
    )
  end

  def test_should_initialize_with_no_dependencies
    assert_nothing_raised do
      Clipper::TypeMap.new
    end
  end

  def test_can_add_new_signatures
    typemap = Clipper::TypeMap.new
    assert_nothing_raised do
      typemap << @signature
    end

    assert_raises(ArgumentError) do
      typemap << nil
    end
  end

  def test_signatures_are_uniqued
    typemap = Clipper::TypeMap.new

    assert_nothing_raised do
      typemap << @signature
      typemap << @signature
    end

    assert_equal(1, typemap.size)

    duplicate = Clipper::TypeMap::Signature.new(
      [String],
      [Integer],
      lambda { },
      lambda { }
    )

    typemap << duplicate
    assert_equal(1, typemap.size)

    other = Clipper::TypeMap::Signature.new(
      [String],
      [String],
      lambda { },
      lambda { }
    )

    typemap << other
    assert_equal(2, typemap.size)
  end
end