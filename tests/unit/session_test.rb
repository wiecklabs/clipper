require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class SessionTest < Test::Unit::TestCase

  def setup
    Beacon::Repositories::register("default", "abstract://localhost/example")
  end

  def teardown
    Beacon::Repositories::registrations.delete("default")
  end

  def test_can_initialize_a_session
    assert_nothing_raised do
      Beacon::Session.new("default")
    end
    assert_nothing_raised do
      session = orm("default")
    end
  end

  def test_has_a_repository
    session = Beacon::Session.new("default")
    assert_respond_to(session, :repository)
    assert_equal(Beacon::Repositories::registrations["default"], session.repository)
  end
  
  def test_has_a_mappings_shortcut
    session = Beacon::Session.new("default")
    assert_respond_to(session, :mappings)
    assert_kind_of(Beacon::Mappings, session.mappings)
  end
end