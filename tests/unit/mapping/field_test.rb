require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class FieldTest < Test::Unit::TestCase

  Field = Clipper::Mapping::Field

  def setup
    @zoo = Class.new do
      include Clipper::Accessors

      accessor :name => String
    end

    @type = Class.new do
      include Clipper::Repository::Type
    end.new

    @accessor = @zoo.accessors[:name]
    @name = "name"
  end

  def test_new_with_valid_arguments
    assert_nothing_raised do
      Field.new(@type, @accessor, @name)
    end
  end

  def test_requires_type_instance
    assert_raise(ArgumentError) do
      Field.new(Class.new, @accessor, @name)
    end
  end

  def test_requires_repository_type
    assert_raise(ArgumentError) do
      Field.new(Class.new.new, @accessor, @name)
    end
  end

  def test_requires_clipper_accessor
    assert_raise(ArgumentError) do
      Field.new(@type, Class.new.new, @name)
    end
  end

  def test_name_defaults_to_provided_name
    field = Field.new(@type, @accessor, @name)

    assert_equal("name", field.name)
  end

  def test_type_name_overrides_default_name
    @type.name = "type_name"

    field = Field.new(@type, @accessor, @name)

    assert_equal("type_name", field.name)
  ensure
    @type.name = nil
  end

end