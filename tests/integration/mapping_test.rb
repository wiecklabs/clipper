require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::MappingTest < Test::Unit::TestCase

  def setup
    uri = Clipper::Uri.new("abstract://localhost/example")
    @repository = Clipper::registrations["abstract"] = Clipper::Repositories::Abstract.new("abstract", uri)
    @session = Clipper::Session.new("abstract")

    @mapped_class = Class.new do
      include Clipper::Accessors

      accessor :id => Integer
    end

    @table_name = "users"
    @id_type = Class.new.new
  end

  def test_field_with_valid_arguments
    flunk("TypeMap must be integrated into Repository to properly test field declarations")

    mapping = Clipper::Mapping.new(@session, @mapped_class, @table_name)

    assert_nothing_raised do
      mapping.field(:id, @id_type)
    end
  end

  def test_field_requires_proper_arguments
    flunk("TypeMap must be integrated into Repository to properly test field declarations")

    mapping = Clipper::Mapping.new(@session, @mapped_class, @table_name)

    assert_raises(ArgumentError) do
      mapping.field(:undeclared_field, @id_type)
    end

    assert_raises(ArgumentError) do
      mapping.field(:id, nil)
    end
  end
end