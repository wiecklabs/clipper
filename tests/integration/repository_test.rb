require "helper"

class RepositoryTest < Test::Unit::TestCase
  
  def setup
    @uri = Wheels::Orm::Uri.new("abstract://localhost/example")
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
  
end