require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::UnitOfWorkTest < Test::Unit::TestCase
  include Clipper::Session::Helper

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

    Clipper::open("default", "abstract://localhost/example")

    @person = Class.new do
      include Clipper::Accessors

      accessor :id => Integer
      accessor :children => Integer
    end

    orm.map(@person, 'person') do |person, type|
      person.field(:id, @repository_type.new)
      person.field(:children, @repository_type.new)
    end
    @uow = orm.unit_of_work
  end

  def test_getting_model_proxy
    person = @person.new
    person.id = 1
    person.children = 4

    @uow.register_clean(person)
    
    assert(@uow.proxy_for(person).is_a?(Clipper::Model::Proxy))
  end
end