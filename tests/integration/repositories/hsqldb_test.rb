require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"
require Pathname(__FILE__).dirname + "abstract"

class Integration::HsqldbTest < Test::Unit::TestCase

  include Integration::AbstractRepositoryTest

  def setup
    @uri = Beacon::Uri.new("jdbc:hsqldb:mem:test")

    Beacon::open("default", @uri.to_s)

    setup_abstract
  end

  def teardown
    Beacon::registrations.delete("default")
  end

  def test_connection_works
    Beacon::registrations["default"].with_connection do |connection|
      assert_equal(false, connection.getMetaData.supportsGetGeneratedKeys)
    end
  end

end