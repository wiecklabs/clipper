require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::CollectionTest < Test::Unit::TestCase
  
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
  
  def test_should_have_an_indexer
    assert_equal(1, Beacon::Collection.new(@mapping, [1])[0])
  end
end