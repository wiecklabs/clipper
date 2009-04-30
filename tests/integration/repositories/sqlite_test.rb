require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"
require Pathname(__FILE__).dirname + "abstract"

class Integration::SqliteTest < Test::Unit::TestCase

  include Integration::AbstractRepositoryTest

  def setup
    @sqlite_path = Pathname(__FILE__).dirname.expand_path + "sqlite.db"
    @uri = Beacon::Uri.new("jdbc:sqlite://#{@sqlite_path}")

    Beacon::Repositories::register("default", @uri.to_s)

    setup_abstract
  end

  def teardown
    Beacon::Repositories::registrations.delete("default")
    File.unlink(@sqlite_path) rescue nil
  end

  def test_get_driver_from_uri
    assert_equal(Beacon::Repositories::Jdbc::Sqlite, @uri.driver)
  end

  def test_connecting_should_create_database
    driver = @uri.driver.new("default", @uri)
    driver.with_connection {}
    assert(File.exists?(@sqlite_path))
  end

  def test_has_a_syntax
    assert_kind_of(Beacon::Syntax::Sql, Beacon::Repositories.registrations["default"].syntax)
  end

  def test_schema_raises_for_unmapped_classes
    schema = Beacon::Schema.new("default")
    assert_raise(Beacon::Mappings::UnmappedClassError) { schema.create(Class.new) }
  end

end