require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class TypeMapTest < Test::Unit::TestCase

  def setup
    typecast_left_procedure = lambda { |age| age.to_s }
    typecast_right_procedure = lambda { |age| age.to_i }

    @signature_one = Clipper::TypeMap::Signature.new(
      [String],
      [Integer],
      lambda { |age| age.to_s },
      lambda { |age| age.to_i }
    )

    @signature_two = Clipper::TypeMap::Signature.new(
      [String],
      [String],
      lambda { |name| name.to_s },
      lambda { |name| name.to_s }
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
      typemap << @signature_one
    end

    assert_raises(ArgumentError) do
      typemap << nil
    end
  end

  def test_signatures_are_uniqued
    typemap = Clipper::TypeMap.new

    assert_nothing_raised do
      typemap << @signature_one
      typemap << @signature_one
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

    typemap << @signature_two
    assert_equal(2, typemap.size)
  end

  def test_matching_signature
    typemap = Clipper::TypeMap.new
    typemap << @signature_one
    typemap << @signature_two

    assert_nothing_raised do
      assert(typemap.match([String], [Integer]).is_a?(Clipper::TypeMap::Signature))
    end

    assert_raises(Clipper::TypeMap::MatchError) do
      typemap.match([Integer], [Integer])
    end
  end
end