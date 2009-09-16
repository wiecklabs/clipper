require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::SessionTest < Test::Unit::TestCase
  def setup
    @person = Class.new do
      include Clipper::Model

      constrain("default")
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

  def test_validate
    session = Clipper::Session.new("default")

    assert_nothing_raised do
      result = session.validate(@person.new)
      assert(result.is_a?(Clipper::Validations::ValidationResult))
    end
  end

  def test_map_type_adds_signature_to_repository_type_map
    session = Clipper::Session.new("default")
    datetime = string = nil
    session.map_type do |signature, types|
      signature.from [(datetime = types.date_time)]
      signature.to [(string = types.string)]
      signature.typecast_left lambda { }
      signature.typecast_right lambda { }
    end

    assert_nothing_raised do
      session.repository.class.type_map.match([datetime], [string])
    end
  end
end