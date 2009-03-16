require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::ValidationsTest < Test::Unit::TestCase

  def setup
    Wheels::Orm::Repositories::register("default", "abstract://localhost/example")
    @user = Class.new do
      attr_accessor :password_confirmation
      
      orm.map(self, "users") do |users|
        users.key "id", Integer
        users.field "name", Wheels::Orm::Types::String.new(200)
        users.field "email", Wheels::Orm::Types::String.new(200)
        users.field "password", Wheels::Orm::Types::String.new(200)
        users.field "age", Wheels::Orm::Types::Integer
        users.field "gender", Wheels::Orm::Types::String.new(200)
        users.field "title", Wheels::Orm::Types::String.new(200)
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

  def test_default_validation_returns_invalid_result
    @users.constrain('default') do |check|
      check.required('name')
    end

    user = @user.new
    result = orm.validate(user)
    assert_equal(false, result.valid?)
    assert_equal(1, result.errors.size)
  end

  def test_default_validation_returns_valid_result
    @users.constrain('default') do |check|
      check.required('name')
    end

    user = @user.new
    user.name = 'Sample User'
    result = orm.validate(user)
    assert_equal(true, result.valid?)
    assert_equal(0, result.errors.size)
  end

  def test_multiple_context_validation
    @users.constrain('email_marketing') do |check|
      check.required('name')
      check.required('email')
    end

    # Validate in the default context
    user = @user.new
    user.name = 'Sample User'
    result = orm.validate(user)
    assert_equal(true, result.valid?)
    assert_equal(0, result.errors.size)

    # Validate in the email_marketing context
    user = @user.new
    result = orm.validate(user, 'email_marketing')
    assert_equal(false, result.valid?)
    assert_equal(2, result.errors.size)
  end

end