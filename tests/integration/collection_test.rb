require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::CollectionTest < Test::Unit::TestCase
  
  def setup
    @uri = Wheels::Orm::Uri.new("abstract://localhost/example")
    Wheels::Orm::Repositories::register("example", @uri.to_s)
    
    @person = Class.new do
      Wheels::Orm::Mappings["example"].map(self, "people") do |people|
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
  
  def test_should_have_an_indexer
    assert_equal(1, Wheels::Orm::Collection.new(@mapping, [1])[0])
  end
end