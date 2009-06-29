require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class TypedAccessorTest < Test::Unit::TestCase

  class Person
    include Clipper::Accessors

    accessor :name => String
    accessor :age => Integer
  end

  def test_accessing_types
    assert_equal(String, Person.accessors[:name].type)
    assert_equal(Integer, Person.accessors[:age].type)
  end

  def test_basic_type_casting
    bob = Person.new
    bob.name = "Bob"
    bob.age = "30"

    assert_equal("Bob", bob.name)
    assert_equal(30, bob.age)
  end

  def test_get
    bob = Person.new
    bob.name = "Bob"

    assert_equal("Bob", Person.accessors[:name].get(bob))
  end

  def test_set
    bob = Person.new
    Person.accessors[:name].set(bob, "Bob")

    assert_equal("Bob", bob.name)
  end
end

