require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class SyntaxTest < Test::Unit::TestCase

  def setup
    @uri = Wheels::Orm::Uri.new("jdbc:sqlite:///tmp/syntax.db")
    @repository = @uri.driver.new("default", @uri)

    @syntax = Wheels::Orm::Syntax::Sql.new(@repository)

    @zoos = Wheels::Orm::Mappings::Mapping.new(Class.new, "zoos")
    @zoos.key @zoos.field("id", Wheels::Orm::Types::Serial)
    @zoos.field "city_id", Integer

    @cities = Wheels::Orm::Mappings::Mapping.new(Class.new, "cities")
    @cities.key @cities.field("id", Wheels::Orm::Types::Serial)
  end

  def test_basic_serializations
    assert_equal('"zoos"."id" = ?', @syntax.serialize([:eq, @zoos["id"], 1]))
    assert_equal('"zoos"."id" < ?', @syntax.serialize([:lt, @zoos["id"], 1]))
    assert_equal('"zoos"."id" > ?', @syntax.serialize([:gt, @zoos["id"], 1]))
  end

  def test_serializations_with_mappings
    assert_equal('"zoos"."city_id" = "cities"."id"', @syntax.serialize([:eq, @zoos["city_id"], @cities["id"]]))
  end

end