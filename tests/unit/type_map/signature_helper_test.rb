require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class SignatureHelperTest < Test::Unit::TestCase
  def test_create_signature
    helper = Clipper::TypeMap::SignatureHelper.new
    helper.from [Integer]
    helper.typecast_left lambda { }
    helper.to [String]
    helper.typecast_right lambda { }

    assert(helper.create_signature.match?([Integer], [String]))
  end

  def test_raise_exception_when_creating_an_invalid_signature
    helper = Clipper::TypeMap::SignatureHelper.new
    helper.from nil
    helper.typecast_left nil
    helper.to nil
    helper.typecast_right nil

    assert_raise(ArgumentError) do
      helper.create_signature
    end
  end
end