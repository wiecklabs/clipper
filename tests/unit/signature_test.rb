require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class SignatureTest < Test::Unit::TestCase

  def test_types_must_be_arrays_containing_classes
    assert_nothing_raised do
      Clipper::TypeMap::Signature.new(
        [String, String],   # Attribute Type(s)
        [Integer, Integer], # Repository Type(s)
        lambda { },         # "From" (Attribute Type) Procedure
        lambda { }          # "To" (Attribute Type) Procedure
      )
    end

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

end