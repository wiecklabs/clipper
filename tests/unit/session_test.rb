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

  def test_has_a_repository
    session = Wheels::Orm::Session.new("default")
    assert_respond_to(session, :repository)
    assert_equal(Wheels::Orm::Repositories::registrations["default"], session.repository)
  end
  
  def test_has_a_mappings_shortcut
    session = Wheels::Orm::Session.new("default")
    assert_respond_to(session, :mappings)
    assert_kind_of(Wheels::Orm::Mappings, session.mappings)
  end
end