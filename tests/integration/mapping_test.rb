require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::MappingTest < Test::Unit::TestCase

  def setup
    @id_type = Class.new do
      include Clipper::Repositories::Type
    end

    Clipper::Repositories::Abstract.type_map << Clipper::TypeMap::Signature.new(
      [Integer],
      [@id_type],
      lambda {},
      lambda {}
    )

    uri = Clipper::Uri.new("abstract://localhost/example")
    @repository = Clipper::registrations["abstract"] = Clipper::Repositories::Abstract.new("abstract", uri)
    @session = Clipper::Session.new("abstract")

    @mapped_class = Class.new do
      include Clipper::Accessors

      accessor :id => Integer
    end

    @table_name = "users"
  end

  def test_field_with_valid_arguments
    mapping = Clipper::Mapping.new(@session, @mapped_class, @table_name)

    assert_nothing_raised do
      mapping.field(:id, @id_type.new)
    end
  end

  def test_field_requires_proper_arguments
    mapping = Clipper::Mapping.new(@session, @mapped_class, @table_name)

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
    mapping = Clipper::Mapping.new(@session, @mapped_class, @table_name)
    mapping.field(:id, @id_type.new)

    assert_equal(1, mapping.signatures.size)
    assert_equal(1, mapping.accessors.size)
    assert_equal(1, mapping.types.size)
  end
end