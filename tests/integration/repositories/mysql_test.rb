require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class Integration::MysqlTest < Test::Unit::TestCase
  def setup
    @uri = Wheels::Orm::Uri.new("jdbc:mysql://localhost:3306/worm_test?user=root")

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
      assert_equal(true, connection.getMetaData.supportsGetGeneratedKeys)
    end
  end

  def test_create_schema
    schema = Wheels::Orm::Schema.new("default")
    schema.destroy(@person) rescue nil

    schema.create(@person)
    assert(schema.exists?(@person))
    schema.destroy(@person)
    assert(!schema.exists?(@person))
  end

  def test_insert_one_record
    schema = Wheels::Orm::Schema.new("default")
    schema.destroy(@person) rescue nil

    schema.create(@person)

    person = @person.new
    person.name = "John"
    orm.save(person)

    assert_equal(1, person.id)

    schema.destroy(@person)
  end

  def test_insert_multiple_records
    schema = Wheels::Orm::Schema.new("default")
    schema.destroy(@person) rescue nil

    schema.create(@person)

    person1 = @person.new
    person1.name = "John"

    person2 = @person.new
    person2.name = "Jane"

    people = Wheels::Orm::Collection.new(orm.mappings[@person], [person1, person2])

    orm.save(people)

    assert_equal(1, person1.id)
    assert_equal(2, person2.id)

    schema.destroy(@person)
  end
end