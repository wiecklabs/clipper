require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class RepositoryTest < Test::Unit::TestCase

  def setup
    @uri = Wheels::Orm::Uri.new("abstract://localhost/example")
  end

  def teardown
    Wheels::Orm::Repositories::registrations.delete("example")
  end

  def test_requires_two_arguments
    assert_equal(2, Wheels::Orm::Repositories::Abstract.instance_method("initialize").arity)
  end

  def test_has_a_name_and_uri
    repository = Wheels::Orm::Repositories::Abstract.new("example", @uri)
    assert_equal("example", repository.name)
    assert_equal(@uri, repository.uri)
  end

  def test_registering_a_repository
    repository = Wheels::Orm::Repositories::register("example", @uri.to_s)
    assert_kind_of(Wheels::Orm::Repositories::Abstract, repository)
    assert_equal(1, Wheels::Orm::Repositories::registrations.size)
  end

  def test_retrieving_a_mapping_for_an_instance
    repository = Wheels::Orm::Repositories::register("example", @uri.to_s)

    person = Class.new do
      attr_accessor :name, :age
      orm("example").map(self, "people") do |people|
        people.field "name", String
        people.field "age", Integer
      end
    end

    assert_kind_of(Wheels::Orm::Mappings::Mapping, repository.mappings[person])
  end

end