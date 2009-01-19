require "helper"

class SessionTest < Test::Unit::TestCase

  def setup
    Wheels::Orm::Repositories::register("default", "abstract://localhost/example")
  end

  def teardown
    Wheels::Orm::Repositories::registrations.delete("default")
  end

  def test_can_initialize_a_session
    assert_nothing_raised do
      Wheels::Orm::Session.new("default")
    end
    assert_nothing_raised do
      session = orm("default")
    end
  end

end