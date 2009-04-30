require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::CriteriaTest < Test::Unit::TestCase
  
  def setup
    @uri = Beacon::Uri.new("abstract://localhost/example")
    Beacon::open("example", @uri.to_s)
    
    @person = Class.new do
      Beacon::Mappings["example"].map(self, "people") do |people|
        people.key people.field("id", Beacon::Types::Serial)
        people.field "name", Beacon::Types::String.new(200)
        people.field "gpa", Beacon::Types::Float(7, 2)
      end
    end
    
    @mapping = orm("example").repository.mappings[@person]
  end
  
  def teardown
    Beacon::registrations.delete("example")
  end
  
  def test_options_do_not_have_side_effects_on_conditions
    people = Beacon::Query::Criteria.new(@mapping)
    assert_nothing_raised do
      people.limit 3
      people.order(people.gpa.desc, people.name)
    end
    
    assert_equal({ :limit => 3, :order => [[@mapping["gpa"], :desc], [@mapping["name"], :asc]] }, people.__options__)
    assert_nil(people.__conditions__)
  end
end