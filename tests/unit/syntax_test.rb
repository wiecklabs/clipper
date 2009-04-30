require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class SyntaxTest < Test::Unit::TestCase

  def setup
    @uri = Beacon::Uri.new("jdbc:sqlite:///tmp/syntax.db")
    @repository = @uri.driver.new("default", @uri)

    @syntax = Beacon::Syntax::Sql.new(@repository)

    @zoos = Beacon::Mappings::Mapping.new(Beacon::Mappings.new, Class.new, "zoos")
    @zoos.key @zoos.field("id", Beacon::Types::Serial)
    @zoos.field "city_id", Integer

    @cities = Beacon::Mappings::Mapping.new(Beacon::Mappings.new, Class.new, "cities")
    @cities.key @cities.field("id", Beacon::Types::Serial)
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