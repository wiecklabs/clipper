require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class TypedAccessorTest < Test::Unit::TestCase

  class City
    include Wheels::Orm::Serializable

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
    include Wheels::Orm::Model

    accessor :name => String
    accessor :age => Integer
  end

  def test_accessing_types
    assert_equal(String, Person.accessors[:name].type)
    assert_equal(Integer, Person.accessors[:age].type)
  end

  def test_can_use_a_custom_serializable_type
    assert_nothing_raised do
      Person.accessor :home => City
    end

    assert_equal(City, Person.accessors[:home].type)
  end
end

