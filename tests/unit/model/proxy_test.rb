require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class ProxyTest < Test::Unit::TestCase
  Proxy = Clipper::Model::Proxy

  def setup
    @repository_type = Class.new do
      include Clipper::Repository::Type
    end

    Clipper::Repositories::Abstract.type_map << Clipper::TypeMap::Signature.new(
      [Integer],
      [@repository_type],
      lambda {},
      lambda {}
    )

    uri = Clipper::Uri.new("abstract://localhost/example")
    @repository = Clipper::registrations["abstract"] = Clipper::Repositories::Abstract.new("abstract", uri)

    @person = Class.new do
      include Clipper::Accessors

      accessor :id => Integer
      accessor :children => Integer
    end
    @mapping = Clipper::Mapping.new(@repository, @person, 'table')
    @mapping.field(:id, @repository_type.new)
    @mapping.field(:children, @repository_type.new)
  end

  def test_new_with_valid_arguments
    assert_nothing_raised do
      Proxy.new(Class.new.new, @mapping, nil)
    end

    assert_nothing_raised do
      Proxy.new(Class.new.new, @mapping, {})
    end
  end
  
  def test_requires_mapping
    assert_raise(ArgumentError) do
      Proxy.new(@person.new, Class.new)
    end
  end

  def test_all_values_are_dirty_when_originals_are_nil
    person = @person.new
    person.id = 1
    person.children = 5

    assert_equal(2, Proxy.new(person, @mapping, nil).dirty_values.size)
  end

  def test_dirty_values
    person = @person.new
    person.id = 1
    person.children = 4 # dirty value

    dirty_values = Proxy.new(person, @mapping, {@mapping[:id] => 1, @mapping[:children] => 3}).dirty_values
    assert_equal(1, dirty_values.size)
    dirty_values.each do |value|
      assert_equal('children', value.field.name)
      assert_equal(4, value.get)
      assert_equal(3, value.original)
    end
  end
end