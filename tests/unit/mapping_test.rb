require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class MappingTest < Test::Unit::TestCase

  def setup
    @session = Clipper::Session.new("abstract")

    @mapped_class = Class.new do
      include Clipper::Accessors

      accessor :id => Integer
    end

    @table_name = "users"
    @id_type = Class.new.new
  end

  def test_a_well_formed_mapping
    assert_nothing_raised do
      Clipper::Mapping.new(@session, @mapped_class, @table_name)
    end
  end

  def test_requires_proper_arguments
    assert_raises(ArgumentError) do
      Clipper::Mapping.new(nil, @mapped_class, @table_name)
      Clipper::Mapping.new(nil, Class.new, "classes")
    end

    assert_raises(ArgumentError) do
      Clipper::Mapping.new(@session, nil, @table_name)
    end

    assert_raises(ArgumentError) do
      Clipper::Mapping.new(@session, @mapped_class, nil)
    end
  end

  def test_mapped_class_must_include_accessors
    assert_raises(ArgumentError) do
      Clipper::Mapping.new(@session, Class.new, @table_name)
    end
  end

  def test_map_with_valid_arguments
    assert_nothing_raised do
      Clipper::Mapping.map(@session, @mapped_class, @table_name) {}
    end
  end

  def test_map_yields_mapping_instance
    assert_nothing_raised do
      called = false

      Clipper::Mapping.map(@session, @mapped_class, @table_name) do |map|
        called = true
        assert(map.is_a?(Clipper::Mapping))
      end

      assert(called, "Clipper::Mapping#map did not yield to block.")
    end
  end

end