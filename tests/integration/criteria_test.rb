require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::CriteriaTest < Test::Unit::TestCase
  
  def setup
    @uri = Wheels::Orm::Uri.new("abstract://localhost/example")
    Wheels::Orm::Repositories::register("example", @uri.to_s)
    
    @person = Class.new do
      orm("example").map(self, "people") do |people|
        people.key people.field("id", Wheels::Orm::Types::Serial)
        people.field "name", Wheels::Orm::Types::String.new(200)
        people.field "gpa", Wheels::Orm::Types::Float(7, 2)
      end
    end
    
    @mapping = orm("example").repository.mappings[@person]
  end
  
  def teardown
    Wheels::Orm::Repositories::registrations.delete("example")
  end
  
  def test_options_do_not_have_side_effects_on_conditions
    people = Wheels::Orm::Query::Criteria.new(@mapping)
    assert_nothing_raised do
      people.limit 3
      people.order(people.gpa.desc, people.name)
    end
    
    assert_equal({ :limit => 3, :order => [[@mapping["gpa"], :desc], [@mapping["name"], :asc]] }, people.__options__)
    assert_nil(people.__conditions__)
  end
end