require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class Integration::SqliteTest < Test::Unit::TestCase

  def setup
    @sqlite_path = Pathname(__FILE__).dirname.expand_path + "sqlite.db"
    @uri = Wheels::Orm::Uri.new("jdbc:sqlite://#{@sqlite_path}")

    Wheels::Orm::Repositories::register("default", @uri.to_s)

    @zoo = Class.new do
      orm.map(self, "zoos") do |zoos|
        zoos.key zoos.field("id", Integer)
        zoos.field "name", String
      end
    end

    @city = Class.new do
      orm.map(self, "cities") do |cities|
        cities.key cities.field("name", String)
        cities.field("state", String)
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
end