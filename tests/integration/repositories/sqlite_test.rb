require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"
require Pathname(__FILE__).dirname + "abstract"

class Integration::SqliteTest < Test::Unit::TestCase

  include Integration::AbstractRepositoryTest

  def setup
    @sqlite_path = Pathname(__FILE__).dirname.expand_path + "sqlite.db"
    @uri = Clipper::Uri.new("jdbc:sqlite://#{@sqlite_path}")

    Clipper::open("default", @uri.to_s)

    setup_abstract
  end

  def teardown
    Clipper::registrations.delete("default")
    File.unlink(@sqlite_path) rescue nil
  end

  def test_get_driver_from_uri
    assert_equal(Clipper::Repositories::Jdbc::Sqlite, @uri.driver)
  end

  def test_connecting_should_create_database
    driver = @uri.driver.new("default", @uri)
    driver.with_connection {}
    assert(File.exists?(@sqlite_path))
  end

  def test_has_a_syntax
    assert_kind_of(Clipper::Syntax::Sql, Clipper::registrations["default"].syntax)
  end

  def test_schema_raises_for_unmapped_classes
    schema = Clipper::Schema.new("default")
    assert_raise(Clipper::Mappings::UnmappedClassError) { schema.create(Class.new) }
  end

end