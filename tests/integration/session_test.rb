require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::SessionTest < Test::Unit::TestCase
  def setup
    @person = Class.new do
      include Clipper::Model
    end

    Clipper::open("default", "abstract://localhost/example")
  end

  def teardown
    Clipper::registrations.delete("default")
  end

  def test_map_returns_mapping
    session = Clipper::Session.new("default")

    assert_nothing_raised do
      session.map(@person, "people")
    end
  end

  def test_map_adds_mapping_to_mappings
    session = Clipper::Session.new("default")

    mapping = nil

    assert_nothing_raised do
      mapping = session.map(@person, "people")
    end

    assert_equal(mapping, session.mappings[@person])
  end

end