require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"
require Pathname(__FILE__).dirname + "abstract"

class Integration::MysqlTest < Test::Unit::TestCase

  include Integration::AbstractRepositoryTest

  def setup
    @uri = Beacon::Uri.new("jdbc:mysql://localhost:3306/worm_test?user=root")

    Beacon::open("default", @uri.to_s)

    setup_abstract
  end

  def teardown
    Beacon::registrations.delete("default")
  end

  def test_connection_works
    Beacon::registrations["default"].with_connection do |connection|
      assert_equal(true, connection.getMetaData.supportsGetGeneratedKeys)
    end
  end

end