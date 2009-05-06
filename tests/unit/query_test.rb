require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class QueryTest < Test::Unit::TestCase
  def setup
    @uri = Clipper::Uri.new("jdbc:sqlite:///tmp/syntax.db")
    @repository = @uri.driver.new("default", @uri)

    @syntax = Clipper::Syntax::Sql.new(@repository)

    @zoos = Clipper::Mappings::Mapping.new(Clipper::Mappings.new, Class.new, "zoos")
    @zoos.key @zoos.field("id", Clipper::Types::Serial)
    @zoos.field "city_id", Integer

    @cities = Clipper::Mappings::Mapping.new(Clipper::Mappings.new, Class.new, "cities")
    @cities.field("city", Clipper::Types::String.new(200))
    @cities.field("state", Clipper::Types::String.new(200))
    @cities.key(@cities["city"], @cities["state"])
  end

  def test_query
    # id_conditions = Clipper::Query::Condition.new(:eq, @zoos["id"], 1)
    # query = Clipper::Query.new(@zoos, id_conditions)
    # puts Clipper::Syntax::Sql.new(@repository).serialize(query.conditions)
    # 
    # city_condition = Clipper::Query::Condition.new(:eq, @cities["city"], "Dallas")
    # state_condition = Clipper::Query::Condition.new(:eq, @cities["state"], "Texas")
    # 
    # city_state = Clipper::Query::AndExpression.new(city_condition, state_condition)
    # 
    # query = Clipper::Query.new(@cities, city_state)
    # puts Clipper::Syntax::Sql.new(@repository).serialize(query.conditions)
  end

  def test_query_paramaters_with_unbound_condition
    id_conditions = Clipper::Query::Condition.new(:eq, @zoos["id"], 1)
    query = Clipper::Query.new(@zoos, nil, id_conditions)

    assert_equal([1], query.paramaters)
  end

  def test_query_paramaters_with_expression
    city_condition = Clipper::Query::Condition.new(:eq, @cities["city"], "Dallas")
    state_condition = Clipper::Query::Condition.new(:eq, @cities["state"], "Texas")

    city_state = Clipper::Query::AndExpression.new(city_condition, state_condition)
    query = Clipper::Query.new(@cities, nil, city_state)

    assert_equal(["Dallas", "Texas"], query.paramaters)
  end
end