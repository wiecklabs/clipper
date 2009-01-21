require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::ValidationsTest < Test::Unit::TestCase

  def setup
    Wheels::Orm::Repositories::register("default", "abstract://localhost/example")
    @user = Class.new do
      attr_accessor :password_confirmation
      
      orm.map(self, "users") do |zoos|
        zoos.key "id", Integer
        zoos.field "name", Wheels::Orm::Types::String
        zoos.field "password", Wheels::Orm::Types::String
        zoos.field "age", Wheels::Orm::Types::Integer
      end
    end
  end
  
  def teardown
    Wheels::Orm::Repositories::registrations.delete("default")
  end
  
  def test_constraint_declarations
    
    assert_nothing_raised do
      orm.repository.mappings[@user].constrain("activation") do |check|
        check.size("name", 50) { |instance| instance.active? }
        check.required("name")
        check.unique("name")
        
        check.minimum("age", 21)
        
        check.required("password")
        check.equal("password", "password_confirmation")
      end
    end
    
  end
end