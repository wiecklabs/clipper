require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class QueryTest < Test::Unit::TestCase
  def setup
    @uri = Wheels::Orm::Uri.new("jdbc:sqlite:///tmp/syntax.db")
    @repository = @uri.driver.new("default", @uri)

    @syntax = Wheels::Orm::Syntax::Sql.new(@repository)

    @zoos = Wheels::Orm::Mappings::Mapping.new(Class.new, "zoos")
    @zoos.key @zoos.field("id", Wheels::Orm::Types::Serial)
    @zoos.field "city_id", Integer

    @cities = Wheels::Orm::Mappings::Mapping.new(Class.new, "cities")
    @cities.field("city", Wheels::Orm::Types::String.new(200))
    @cities.field("state", Wheels::Orm::Types::String.new(200))
    @cities.key(@cities["city"], @cities["state"])
  end

  def test_query
    # id_conditions = Wheels::Orm::Query::Condition.new(:eq, @zoos["id"], 1)
    # query = Wheels::Orm::Query.new(@zoos, id_conditions)
    # puts Wheels::Orm::Syntax::Sql.new(@repository).serialize(query.conditions)
    # 
    # city_condition = Wheels::Orm::Query::Condition.new(:eq, @cities["city"], "Dallas")
    # state_condition = Wheels::Orm::Query::Condition.new(:eq, @cities["state"], "Texas")
    # 
    # city_state = Wheels::Orm::Query::AndExpression.new(city_condition, state_condition)
    # 
    # query = Wheels::Orm::Query.new(@cities, city_state)
    # puts Wheels::Orm::Syntax::Sql.new(@repository).serialize(query.conditions)
  end

  def test_query_paramaters_with_unbound_condition
    id_conditions = Wheels::Orm::Query::Condition.new(:eq, @zoos["id"], 1)
    query = Wheels::Orm::Query.new(@zoos, nil, id_conditions)

    assert_equal([1], query.paramaters)
  end

  def test_query_paramaters_with_expression
    city_condition = Wheels::Orm::Query::Condition.new(:eq, @cities["city"], "Dallas")
    state_condition = Wheels::Orm::Query::Condition.new(:eq, @cities["state"], "Texas")

    city_state = Wheels::Orm::Query::AndExpression.new(city_condition, state_condition)
    query = Wheels::Orm::Query.new(@cities, nil, city_state)

    assert_equal(["Dallas", "Texas"], query.paramaters)
  end
end