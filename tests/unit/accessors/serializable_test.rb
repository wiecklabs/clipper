require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class SerializableTest < Test::Unit::TestCase

  class City
    include Clipper::Accessors::Serializable

    attr_accessor :name, :state_abbreviation

    def self.load(reader)
      city = new

      if reader
        city.name = reader[:name]
        city.state_abbreviation = reader[:state_abbreviation]
      end

      city
    end

    def serialize(writer)
      writer[:name] = name
      writer[:state_abbreviation] = state_abbreviation
    end
  end

  class Person
    include Clipper::Accessors
  end

  def test_can_use_a_custom_serializable_type
    assert_nothing_raised do
      Person.accessor :home => City
    end

    assert_equal(City, Person.accessors[:home].type)

    me = Person.new
    me.home = { :name => "Dallas", :state_abbreviation => "TX"}
    assert_equal("Dallas", me.home.name)
    assert_equal("TX", me.home.state_abbreviation)
  end

  def test_serializable_class_determines_default_value
    me = Person.new
    assert_kind_of(City, me.home)
  end

  def test_default_load_raises_error_when_clipper_accessor_not_included
    type = Class.new do
      include Clipper::Accessors::Serializable
    end

    assert_raises(Clipper::Accessors::SerializationError) { type.load("value") }
  end

  def test_default_load_raises_error_when_no_accessors_defined
    type = Class.new do
      include Clipper::Accessors
      include Clipper::Accessors::Serializable
    end

    assert_raises(Clipper::Accessors::SerializationError) { type.load({ :city => "City" }) }
  end

  def test_default_load_handles_hash
    type = Class.new do
      include Clipper::Accessors
      include Clipper::Accessors::Serializable

      accessor :city => String
    end

    assert_nothing_raised do
      value = type.load({ :city => "City" })
      assert(value.is_a?(type))
      assert_equal("City", value.city)
    end
  end

end

