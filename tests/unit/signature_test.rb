require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class SignatureTest < Test::Unit::TestCase

  def test_a_well_formed_signature
    assert_nothing_raised do
      Clipper::TypeMap::Signature.new(
        [String, String],   # Attribute Type(s)
        [Integer, Integer], # Repository Type(s)
        lambda { },         # typecast_left_procedure (Repository to Attribute) Procedure
        lambda { }          # typecast_right_procedure (Attribute to Repository) Procedure
      )
    end
  end

  def test_types_must_be_arrays_containing_classes
    assert_raises(ArgumentError) do
      Clipper::TypeMap::Signature.new(
        nil,
        [Integer, Integer],
        lambda { },
        lambda { }
      )
    end

    assert_raises(ArgumentError) do
      Clipper::TypeMap::Signature.new(
        ["one", "two"],
        [Integer, Integer],
        lambda { },
        lambda { }
      )
    end
  end

  def test_procedures_must_respond_to_call
    assert_raises(ArgumentError) do
      Clipper::TypeMap::Signature.new(
        [String, String],
        [Integer, Integer],
        nil,
        lambda { }
      )
    end

    assert_nothing_raised do

      conversion = Class.new do
        def self.call(*args)
          nil
        end
      end

      Clipper::TypeMap::Signature.new(
        [String, String],
        [Integer, Integer],
        conversion,
        lambda { }
      )
    end
  end

  def test_matching
    signature = Clipper::TypeMap::Signature.new(
      [String, String],
      [Integer, Integer],
      lambda { },
      lambda { }
    )

    assert(signature.match?([String, String], [Integer, Integer]))
    assert(!signature.match?([String], [Integer, Integer]))
    assert(!signature.match?(nil, nil))
  end

  def test_type_casting
    typecast_left_procedure = lambda { |age| age.to_s }
    typecast_right_procedure = lambda { |age| age.to_i }

    signature = Clipper::TypeMap::Signature.new(
      [String],
      [Integer],
      typecast_left_procedure,
      typecast_right_procedure
    )

    assert_nothing_raised do
      signature.typecast_left(2)
    end

    assert_nothing_raised do
      signature.typecast_left(nil)
    end

    assert_raises(ArgumentError) do
      signature.typecast_left("one")
    end
  end

end