require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"
require Pathname(__FILE__).dirname + "abstract"

class Integration::HsqldbTest < Test::Unit::TestCase

  include Integration::AbstractRepositoryTest

  def setup
    @uri = Wheels::Orm::Uri.new("jdbc:hsqldb:mem:test")

    Wheels::Orm::Repositories::register("default", @uri.to_s)

    setup_abstract
  end

  def teardown
    Wheels::Orm::Repositories::registrations.delete("default")
  end

  def test_connection_works
    Wheels::Orm::Repositories.registrations["default"].with_connection do |connection|
      assert_equal(false, connection.getMetaData.supportsGetGeneratedKeys)
    end
  end

end