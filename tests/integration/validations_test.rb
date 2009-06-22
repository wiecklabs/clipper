require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::ValidationsTest < Test::Unit::TestCase

  def setup
    @user = Class.new do
      include Clipper::Validations
      attr_accessor :id, :name, :email, :password, :password_confirmation, :age, :gender, :title
    end

  end

  def test_constraint_declarations
    assert_nothing_raised do
      @user.constrain("test_constraint_declarations") do |check|
        check.size("name", 50) { |instance| instance.active? }
        check.required("name")
  
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
    @user.constrain('default') do |check|
      check.required('name')
    end

    user = @user.new
    result = Clipper::validate(user)
    assert_equal(false, result.valid?)
    assert_equal(1, result.errors.size)
  end

  def test_default_validation_returns_valid_result
    @user.constrain('default') do |check|
      check.required('name')
    end
  
    user = @user.new
    user.name = 'Sample User'
    result = Clipper::validate(user)
    assert_equal(true, result.valid?)
    assert_equal(0, result.errors.size)
  end
  
  def test_multiple_context_validation
    @user.constrain('default') do |check|
      check.required('name')
    end
  
    @user.constrain('email_marketing') do |check|
      check.required('name')
      check.required('email')
    end
  
    # Validate in the default context
    user = @user.new
    user.name = 'Sample User'
    result = Clipper::validate(user)
    assert_equal(true, result.valid?)
    assert_equal(0, result.errors.size)
  
    # Validate in the email_marketing context
    user = @user.new
    result = Clipper::validate(user, 'email_marketing')
    assert_equal(false, result.valid?)
    assert_equal(2, result.errors.size)
  end

end