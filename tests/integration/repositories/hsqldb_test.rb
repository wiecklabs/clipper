require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class Integration::HsqldbTest < Test::Unit::TestCase
  def setup
    @uri = Wheels::Orm::Uri.new("jdbc:hsqldb:mem:test")

    Wheels::Orm::Repositories::register("default", @uri.to_s)

    @person = Class.new do
      orm.map(self, "people") do |people|
        people.key people.field("id", Wheels::Orm::Types::Serial)
        people.field "name", String
        people.field "gpa", Float
      end
    end
  end

  def teardown
    Wheels::Orm::Repositories::registrations.delete("default")
  end

  def test_connection_works
    Wheels::Orm::Repositories.registrations["default"].with_connection do |connection|
      assert_equal(false, connection.getMetaData.supportsGetGeneratedKeys)
    end
  end

  def test_create_schema
    schema = Wheels::Orm::Schema.new("default")
    assert(!schema.exists?(@person))

    schema.create(@person)
    assert(schema.exists?(@person))

    schema.destroy(@person)
    assert(!schema.exists?(@person))
  end

  def test_insert_one_record
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@person)

    person = @person.new
    person.name = "John"
    orm.save(person)

    assert_equal(0, person.id)
  ensure
    schema.destroy(@person)
  end

  def test_insert_multiple_records
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@person)

    person1 = @person.new
    person1.name = "John"

    person2 = @person.new
    person2.name = "Jane"

    people = Wheels::Orm::Collection.new(orm.mappings[@person], [person1, person2])

    orm.save(people)

    assert_equal(0, person1.id)
    assert_equal(1, person2.id)
  ensure
    schema.destroy(@person)
  end
end