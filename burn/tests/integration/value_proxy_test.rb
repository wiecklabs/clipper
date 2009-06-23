require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"
require Pathname(__FILE__).dirname + "sample_models"

class ValueProxyTest < Test::Unit::TestCase

  include Clipper::Session::Helper
  include Integration::SampleModels

  def setup
    Clipper::open("default", "jdbc:hsqldb:mem:test")

    @person = orm.mappings[Person]
    @id = @person["id"]
    @enabled = @person["enabled"]

    @schema = Clipper::Schema.new("default")
    @schema.create(Person)

    orm << Person.new
  end

  def teardown
    @schema.destroy(Person)
    Clipper::close("default")
  end

  def test_blank_value_is_not_dirty
    assert(!@id.value(Person.new).dirty?)
  end

  def test_field_with_default_value_is_dirty
    assert(@enabled.value(Person.new).dirty?)
  end

  def test_fetched_record_is_not_dirty
    person = orm.get(Person, 0)

    assert(!@id.value(person).dirty?)
    assert(!@enabled.value(person).dirty?)
  end

  def test_record_is_not_dirty_after_create
    person = Person.new
    orm << person

    assert(!@id.value(person).dirty?)
    assert(!@enabled.value(person).dirty?)
  end

  def test_record_is_not_dirty_after_update
    person = orm.get(Person, 0)

    person.enabled = 0

    assert(@enabled.value(person).dirty?)
    orm << person

    assert(!@enabled.value(person).dirty?)
  end

end