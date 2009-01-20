require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class Integration::SqliteTest < Test::Unit::TestCase

  def setup
    @sqlite_path = Pathname(__FILE__).dirname.expand_path + "sqlite.db"
    @uri = Wheels::Orm::Uri.new("jdbc:sqlite://#{@sqlite_path}")
  end

  def teardown
    # File.unlink(@sqlite_path) rescue nil
  end

  def test_get_driver_from_uri
    assert_equal(Wheels::Orm::Repositories::Jdbc::Sqlite, @uri.driver)
  end

end