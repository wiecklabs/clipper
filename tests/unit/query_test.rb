require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class QueryTest < Test::Unit::TestCase
  def setup
    @uri = Beacon::Uri.new("jdbc:sqlite:///tmp/syntax.db")
    @repository = @uri.driver.new("default", @uri)

    @syntax = Beacon::Syntax::Sql.new(@repository)

    @zoos = Beacon::Mappings::Mapping.new(Beacon::Mappings.new, Class.new, "zoos")
    @zoos.key @zoos.field("id", Beacon::Types::Serial)
    @zoos.field "city_id", Integer

    @cities = Beacon::Mappings::Mapping.new(Beacon::Mappings.new, Class.new, "cities")
    @cities.field("city", Beacon::Types::String.new(200))
    @cities.field("state", Beacon::Types::String.new(200))
    @cities.key(@cities["city"], @cities["state"])
  end

  def test_query
    # id_conditions = Beacon::Query::Condition.new(:eq, @zoos["id"], 1)
    # query = Beacon::Query.new(@zoos, id_conditions)
    # puts Beacon::Syntax::Sql.new(@repository).serialize(query.conditions)
    # 
    # city_condition = Beacon::Query::Condition.new(:eq, @cities["city"], "Dallas")
    # state_condition = Beacon::Query::Condition.new(:eq, @cities["state"], "Texas")
    # 
    # city_state = Beacon::Query::AndExpression.new(city_condition, state_condition)
    # 
    # query = Beacon::Query.new(@cities, city_state)
    # puts Beacon::Syntax::Sql.new(@repository).serialize(query.conditions)
  end

  def test_query_paramaters_with_unbound_condition
    id_conditions = Beacon::Query::Condition.new(:eq, @zoos["id"], 1)
    query = Beacon::Query.new(@zoos, nil, id_conditions)

    assert_equal([1], query.paramaters)
  end

  def test_query_paramaters_with_expression
    city_condition = Beacon::Query::Condition.new(:eq, @cities["city"], "Dallas")
    state_condition = Beacon::Query::Condition.new(:eq, @cities["state"], "Texas")

    city_state = Beacon::Query::AndExpression.new(city_condition, state_condition)
    query = Beacon::Query.new(@cities, nil, city_state)

    assert_equal(["Dallas", "Texas"], query.paramaters)
  end
end