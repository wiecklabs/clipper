require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::MappingTest < Test::Unit::TestCase

  def setup
    @id_type = Class.new do
      include Clipper::Repository::Type
    end

    Clipper::Repositories::Abstract.type_map << Clipper::TypeMap::Signature.new(
      [Integer],
      [@id_type],
      lambda {},
      lambda {}
    )

    uri = Clipper::Uri.new("abstract://localhost/example")
    @repository = Clipper::registrations["abstract"] = Clipper::Repositories::Abstract.new("abstract", uri)

    @mapped_class = Class.new do
      include Clipper::Accessors

      accessor :id => Integer
    end

    @table_name = "users"
  end

  def test_field_with_valid_arguments
    mapping = Clipper::Mapping.new(@repository, @mapped_class, @table_name)

    assert_nothing_raised do
      mapping.field(:id, @id_type.new)
    end
  end

  def test_field_requires_proper_arguments
    mapping = Clipper::Mapping.new(@repository, @mapped_class, @table_name)

    assert_raises(ArgumentError) do
      mapping.field(:undeclared_accessor, @id_type.new)
    end

    assert_raises(ArgumentError) do
      mapping.field(:id, @id_type)
    end

    assert_raises(Clipper::TypeMap::MatchError) do
      mapping.field(:id, nil)
    end
  end

  def test_field_adds_signature_accessor_and_types
    mapping = Clipper::Mapping.new(@repository, @mapped_class, @table_name)
    mapping.field(:id, @id_type.new)

    assert_equal(1, mapping.signatures.size)
    assert_equal(1, mapping.accessors.size)
    assert_equal(1, mapping.types.size)
  end

  def test_accessing_fields
    mapping = Clipper::Mapping.new(@repository, @mapped_class, @table_name)
    assert_raise(Clipper::Mapping::UnmappedFieldError) do
      mapping[:id]
    end
    field = mapping.field(:id, @id_type.new)
    assert_equal(mapping[:id], field)
  end

  def test_field_has_a_mapping
    mapping = Clipper::Mapping.new(@repository, @mapped_class, @table_name)
    mapping.field(:id, @id_type.new)

    assert_not_nil(mapping[:id].mapping, mapping)
  end

  def test_key_with_proper_arguments
    mapping = Clipper::Mapping.new(@repository, @mapped_class, @table_name)
    mapping.field(:id, @id_type.new)

    assert_nothing_raised do
      mapping.key(:id)
    end
  end

  def test_key_can_only_be_called_once
    mapping = Clipper::Mapping.new(@repository, @mapped_class, @table_name)
    mapping.field(:id, @id_type.new)
    mapping.key(:id)

    assert_raises(ArgumentError) do
      mapping.key(:id)
    end
  end

  def test_key_requires_field_to_be_declared
    mapping = Clipper::Mapping.new(@repository, @mapped_class, @table_name)

    assert_raises(Clipper::Mapping::UnmappedFieldError) do
      mapping.key(:id)
    end
  end

  def test_is_key
    mapping = Clipper::Mapping.new(@repository, @mapped_class, @table_name)
    id = mapping.field(:id, @id_type.new)
    mapping.key(:id)

    assert(mapping.is_key?(id))
  end

  def test_property
    mapping = Clipper::Mapping.new(@repository, @mapped_class, @table_name)
    assert_nothing_raised do
      mapping.property(:id, Integer, @id_type.new)
    end
  end

  def test_property_defines_an_accessor
    mapping = Clipper::Mapping.new(@repository, @mapped_class, @table_name)
    mapping.property(:property, Integer, @id_type.new)

    assert_not_nil(@mapped_class.accessors[:property])
  end

  def test_property_adds_a_field_to_mapping
    mapping = Clipper::Mapping.new(@repository, @mapped_class, @table_name)
    mapping.property(:property, Integer, @id_type.new)

    assert_nothing_raised { mapping[:property] }
  end
end