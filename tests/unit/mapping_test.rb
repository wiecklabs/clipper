require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class MappingTest < Test::Unit::TestCase

  def setup
    @repository = Clipper::Repositories::Abstract.new("abstract", Clipper::Uri.new("abstract://localhost/example"))

    @target = Class.new do
      include Clipper::Accessors

      accessor :id => Integer
    end

    @name = "users"
    @id_type = Class.new.new
  end

  def test_a_well_formed_mapping
    assert_nothing_raised do
      Clipper::Mapping.new(@repository, @target, @name)
    end
  end

  def test_has_a_name
    assert_equal(@name, Clipper::Mapping.new(@repository, @target, @name).name)
  end

  def test_requires_proper_arguments
    assert_raises(ArgumentError) do
      Clipper::Mapping.new(nil, @target, @name)
      Clipper::Mapping.new(nil, Class.new, "classes")
    end

    assert_raises(ArgumentError) do
      Clipper::Mapping.new(@repository, nil, @name)
    end

    assert_raises(ArgumentError) do
      Clipper::Mapping.new(@repository, @target, nil)
    end
  end

  def test_target_must_include_accessors
    assert_raises(ArgumentError) do
      Clipper::Mapping.new(@repository, Class.new, @name)
    end
  end

  def test_map_with_valid_arguments
    assert_nothing_raised do
      Clipper::Mapping.map(@repository, @target, @name) {}
    end
  end

  def test_map_yields_mapping_instance
    assert_nothing_raised do
      called = false

      Clipper::Mapping.map(@repository, @target, @name) do |map|
        called = true
        assert(map.is_a?(Clipper::Mapping))
      end

      assert(called, "Clipper::Mapping#map did not yield to block.")
    end
  end

  def test_map_yield_only_when_block_provided
    assert_nothing_raised do
      mapping = Clipper::Mapping.map(@repository, @target, @name)
      assert(mapping.is_a?(Clipper::Mapping))
    end
  end

  def test_keys_are_required
    assert_raise(Clipper::Mapping::NoKeyError) do
      mapping = Clipper::Mapping.new(@repository, @target, @name)
      mapping.keys
    end
  end

end