require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::TypeMapTest < Test::Unit::TestCase
  def test_map_type_adds_signature_to_instance
    type_map = Clipper::TypeMap.new
    type_map.map_type(Types) do |signature, types|
      signature.from [types.date_time]
      signature.to [types.string]
      signature.typecast_left lambda { }
      signature.typecast_right lambda { }
    end

    assert(type_map.match([Types::DateTime], [Types::String]).is_a?(Clipper::TypeMap::Signature))
  end

  def test_map_type_requires_a_module
    assert_raise(ArgumentError) do
      Clipper::TypeMap.new.map_type(Class.new.new)
    end
  end

  private
  module Types
    class String
    end
    class DateTime
    end
  end
end