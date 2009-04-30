require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class SerializableTest < Test::Unit::TestCase

  class City
    include Beacon::Accessors::Serializable

    attr_accessor :name, :state_abbreviation

    def self.load(reader)
      city = new
      city.name = reader[:name].value
      city.state_abbreviation = reader[:state_abbreviation].value
      city
    end

    def serialize(writer)
      writer[:name] = name
      writer[:state_abbreviation] = state_abbreviation
    end
  end

  class Person
    include Beacon::Accessors
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

end

