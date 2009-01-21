require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class Integration::SqliteTest < Test::Unit::TestCase

  def setup
    @sqlite_path = Pathname(__FILE__).dirname.expand_path + "sqlite.db"
    @uri = Wheels::Orm::Uri.new("jdbc:sqlite://#{@sqlite_path}")

    Wheels::Orm::Repositories::register("default", @uri.to_s)

    @zoo = Class.new do
      orm.map(self, "zoos") do |zoos|
        zoos.key zoos.field("id", Wheels::Orm::Types::Serial)
        zoos.field "name", String
      end
    end

    @city = Class.new do
      orm.map(self, "cities") do |cities|
        cities.key cities.field("name", String)
        cities.field("state", String)
      end
    end

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
    File.unlink(@sqlite_path) rescue nil
  end

  def test_get_driver_from_uri
    assert_equal(Wheels::Orm::Repositories::Jdbc::Sqlite, @uri.driver)
  end

  def test_connecting_should_create_database
    driver = @uri.driver.new("default", @uri)
    driver.with_connection {}
    assert(File.exists?(@sqlite_path))
  end

  def test_schema_raises_for_unmapped_classes
    schema = Wheels::Orm::Schema.new("default")
    assert_raise(Wheels::Orm::Mappings::UnmappedClassError) { schema.create(Class.new) }
  end

  def test_schema_creation
    schema = Wheels::Orm::Schema.new("default")
    assert(!schema.exists?(@zoo))
    assert_nothing_raised do
      schema.create(@zoo)
    end
    assert(schema.exists?(@zoo))
    schema.destroy(@zoo)
  end

  def test_schema_exists
    schema = Wheels::Orm::Schema.new("default")
    assert(!schema.exists?(@city))
  end

  def test_field_exists
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@city)
    orm.repository.with_connection do |connection|
      columns = connection.getMetaData.getColumns("", "", "cities", "state")
      assert(columns.next)
    end
    schema.destroy(@city)
  end

  def test_schema_destroy
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@zoo)
    assert_nothing_raised do
      schema.destroy(@zoo)
    end
  end

  def test_save_object
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@zoo)
    zoo = @zoo.new
    zoo.name = "Dallas"

    assert(orm.save(zoo))
    assert_equal(1, zoo.id)

    schema.destroy(@zoo)
  end

  def test_support_for_floats
    schema = Wheels::Orm::Schema.new("default")
    assert_nothing_raised { schema.create(@person) }
    assert_nothing_raised do
      person = @person.new
      person.gpa = 3.5
      orm.save(person)
    end

    schema.destroy(@person)
  end

  def test_get_object
    flunk "orm.get is not implemented yet"

    schema = Wheels::Orm::Schema.new("default")
    schema.create(@person)

    person = orm.get(@person, 1)
    assert_equal("Dallas", person.name)
    assert_equal(3.5, person.gpa)

    schema.destroy(@person)
  end
end