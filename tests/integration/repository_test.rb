require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class RepositoryTest < Test::Unit::TestCase

  def setup
    @uri = Beacon::Uri.new("abstract://localhost/example")
  end

  def teardown
    Beacon::registrations.delete("example")
  end

  def test_requires_two_arguments
    assert_equal(2, Beacon::Repositories::Abstract.instance_method("initialize").arity)
  end

  def test_has_a_name_and_uri
    repository = Beacon::Repositories::Abstract.new("example", @uri)
    assert_equal("example", repository.name)
    assert_equal(@uri, repository.uri)
  end

  def test_registering_a_repository
    repository = Beacon::open("example", @uri.to_s)
    assert_kind_of(Beacon::Repositories::Abstract, repository)
    assert_equal(1, Beacon::registrations.size)
  end

  def test_retrieving_a_mapping_for_an_instance
    repository = Beacon::open("example", @uri.to_s)

    person = Class.new do
      attr_accessor :name, :age
      Beacon::Mappings["example"].map(self, "people") do |people|
        people.field "name", Beacon::Types::String.new(200)
        people.field "age", Beacon::Types::Integer
      end
    end

    assert_kind_of(Beacon::Mappings::Mapping, repository.mappings[person])
  end

  def test_mappings_is_a_mappings_collection
    repository = Beacon::open("example", @uri.to_s)

    assert_kind_of(Beacon::Mappings, repository.mappings)
  end

end