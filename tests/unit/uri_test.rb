require "helper"

class UriTest < Test::Unit::TestCase
    
  def setup
    @uri = Wheels::Orm::Uri.new("abstract://user:password@name?charset=utf8")
    
    dorb = Class.new do
      self.const_set("Sqlite3", Class.new(Wheels::Orm::Repositories::Abstract))
    end
    Wheels::Orm::Repositories.const_set("Dorb", dorb)
  end
  
  def teardown
    Wheels::Orm::Repositories.send(:remove_const, "Dorb")
  end
  
  def test_requires_one_argument
    assert_equal(Wheels::Orm::Uri.instance_method("initialize").arity, 1)
  end
  
  def test_initializes_with_string
    assert_nothing_raised do
      Wheels::Orm::Uri.new("dorb+sqlite3:///#{Dir.pwd}/example.db")
    end
    
    assert_raises(ArgumentError) do
      Wheels::Orm::Uri.new(URI::parse("dorb+sqlite3:///#{Dir.pwd}/example.db"))
    end
    
    assert_raises(ArgumentError) do
      Wheels::Orm::Uri.new(nil)
    end
    
    assert_raises(ArgumentError) do
      Wheels::Orm::Uri.new("")
    end
  end
  
  def test_returns_original_string
    assert_equal("abstract://user:password@name?charset=utf8", @uri.to_s)
  end
  
  def test_has_a_driver
    assert_equal(Wheels::Orm::Repositories::Abstract, @uri.driver)
  end
  
  def test_has_a_name
    assert_equal("name", @uri.name)
  end
  
  def test_has_a_user
    assert_equal("user", @uri.user)
  end
  
  def test_has_a_password
    assert_equal("password", @uri.password)
  end
  
  def test_has_options
    assert_equal({ "charset" => "utf8"}, @uri.options)
  end
end