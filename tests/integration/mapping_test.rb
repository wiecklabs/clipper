require "helper"

class MappingTest < Test::Unit::TestCase
  
  # def test_stuff
  #   example = Wheels::Orm::Repositories::registrations["example"]
  #   
  #   assert_equal($people, example.source(Person))
  # end
  
end

__END__
class Person
  session.map(self, "people") do |mapping|
    mapping.key :id, Integer
    mapping.field :name, String
    mapping.field :organization, mapping::Organization
    
    mapping.map("addresses") do |mapping|
      mapping.field :city, String
      mapping.field :state, String
    end
  end
end
