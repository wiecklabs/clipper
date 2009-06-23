require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

return unless ADAPTERS.include?("mysql")

require Pathname(__FILE__).dirname + "abstract"

class Integration::MysqlTest < Test::Unit::TestCase

  include Integration::AbstractRepositoryTest

  def setup
    @uri = Clipper::Uri.new("jdbc:mysql://localhost:3306/worm_test?user=root")

    Clipper::open("default", @uri.to_s)

    setup_abstract
  end

  def teardown
    Clipper::registrations.delete("default")
  end

  def test_connection_works
    Clipper::registrations["default"].with_connection do |connection|
      assert_equal(true, connection.getMetaData.supportsGetGeneratedKeys)
    end
  end

end