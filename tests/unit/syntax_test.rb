require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class SyntaxTest < Test::Unit::TestCase

  def setup
    @sqlite_path = Pathname(__FILE__).dirname.expand_path + "sqlite.db"
    @uri = Clipper::Uri.new('jdbc:sqlite:///' + @sqlite_path + 'syntax.db')
    @repository = @uri.driver.new("default", @uri)

    @syntax = Clipper::Syntax::Sql.new(@repository)

    @zoos = Clipper::Mappings::Mapping.new(Clipper::Mappings.new, Class.new, "zoos")
    @zoos.key @zoos.field("id", Clipper::Types::Serial)
    @zoos.field "city_id", Integer

    @cities = Clipper::Mappings::Mapping.new(Clipper::Mappings.new, Class.new, "cities")
    @cities.key @cities.field("id", Clipper::Types::Serial)
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