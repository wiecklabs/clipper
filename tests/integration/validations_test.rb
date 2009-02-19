require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::ValidationsTest < Test::Unit::TestCase

  def setup
    Wheels::Orm::Repositories::register("default", "abstract://localhost/example")
    @user = Class.new do
      attr_accessor :password_confirmation
      
      orm.map(self, "users") do |users|
        users.key "id", Integer
        users.field "name", Wheels::Orm::Types::String
        users.field "email", Wheels::Orm::Types::String
        users.field "password", Wheels::Orm::Types::String
        users.field "age", Wheels::Orm::Types::Integer
        users.field "gender", Wheels::Orm::Types::String
        users.field "title", Wheels::Orm::Types::String
      end
    end
    
    @users = orm.repository.mappings[@user]
  end
  
  def teardown
    Wheels::Orm::Repositories::registrations.delete("default")
  end
    
  def test_constraint_declarations
    assert_nothing_raised do
      @users.constrain("test_constraint_declarations") do |check|
        check.size("name", 50) { |instance| instance.active? }
        check.required("name")
        check.unique("name")
        
        check.minimum("age", 21)
        
        check.required("password")
        check.equal("password", "password_confirmation")

        check.format('email', /\w+@\w+\.com/)
        check.within('gender', %w{M F})
        check.within('age', 21..35)

        check.size('address', 21..200)
      end
    end
  end

end