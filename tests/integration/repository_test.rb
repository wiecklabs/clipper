require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class RepositoryTest < Test::Unit::TestCase

  def setup
    @uri = Clipper::Uri.new("abstract://localhost/example")
  end

  def teardown
    Clipper::registrations.delete("example")
  end

  def test_requires_two_arguments
    assert_equal(2, Clipper::Repositories::Abstract.instance_method("initialize").arity)
  end

  def test_has_a_name_and_uri
    repository = Clipper::Repositories::Abstract.new("example", @uri)
    assert_equal("example", repository.name)
    assert_equal(@uri, repository.uri)
  end

  def test_registering_a_repository
    repository = Clipper::open("example", @uri.to_s)
    assert_kind_of(Clipper::Repositories::Abstract, repository)
    assert_equal(1, Clipper::registrations.size)
  end

  def test_retrieving_a_mapping_for_an_instance
    repository = Clipper::open("example", @uri.to_s)

    person = Class.new do
      attr_accessor :name, :age
      Clipper::Mappings["example"].map(self, "people") do |people|
        people.field "name", Clipper::Types::String.new(200)
        people.field "age", Clipper::Types::Integer
      end
    end

    assert_kind_of(Clipper::Mappings::Mapping, repository.mappings[person])
  end

  def test_mappings_is_a_mappings_collection
    repository = Clipper::open("example", @uri.to_s)

    assert_kind_of(Clipper::Mappings, repository.mappings)
  end

end