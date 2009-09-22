require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class SessionTest < Test::Unit::TestCase

  include Clipper::Session::Helper

  def setup
    Clipper::open("default", "abstract://localhost/example")
  end

  def teardown
    Clipper::registrations.delete("default")
  end

  def test_can_initialize_a_session
    assert_nothing_raised do
      Clipper::Session.new("default")
    end
    assert_nothing_raised do
      session = orm("default")
      session = Clipper::Session::Helper.orm('default')
    end
  end

  # def test_has_a_repository
  #   session = Clipper::Session.new("default")
  #   assert_respond_to(session, :repository)
  #   assert_equal(Clipper::registrations["default"], session.repository)
  # end
  # 
  # def test_has_a_mappings_shortcut
  #   session = Clipper::Session.new("default")
  #   assert_respond_to(session, :mappings)
  #   assert_equal(session.repository.mappings, session.mappings)
  # end

end