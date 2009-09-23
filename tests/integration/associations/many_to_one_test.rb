require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"
require Pathname(__FILE__).dirname.parent + "sample_models"

class Integration::ManyToOneTest < Test::Unit::TestCase

  include Clipper::Session::Helper
  include Integration::SampleModels

  def setup
    Clipper::open("default", "jdbc:hsqldb:mem:test")
    load Pathname(__FILE__).dirname.parent + "sample_models_mapping.rb"

    schema = Clipper::Schema.new("default")
    schema.create(Zoo)
    schema.create(ZooKeeper)
    schema.create(Exhibit)
  end

  def teardown
    schema = Clipper::Schema.new("default")
    schema.destroy(Zoo)
    schema.destroy(ZooKeeper)
    schema.destroy(Exhibit)

    Clipper::close("default")
  end

  def test_can_only_be_defined_once
  
    assert_raise(Clipper::Mapping::DuplicateAssociationError) do
      # This association is already defined
      orm.repository.mappings[Exhibit].many_to_one(:zoo, Zoo) do |exhibit, zoo|
        zoo.id.eq(exhibit.zoo_id)
      end
    end
  
  end
  
  def test_belongs_to_defines_getter_on_object
    exhibit = Exhibit.new('Emu')
    assert_respond_to(exhibit, :zoo)
  end

  def test_belongs_to_method_returns_associated_object
    zoo = Zoo.new('Dallas')
    orm.save(zoo)

    exhibit = Exhibit.new('Panda')
    exhibit.zoo_id = zoo.id
    orm.save(exhibit)

    exhibit = orm.get(Exhibit, 0)
    assert_kind_of(Zoo, exhibit.zoo)
    assert_equal(0, exhibit.zoo.id)
  end

  def test_has_many_getter_returns_same_instance
    zoo = Zoo.new('Dallas')
    orm.save(zoo)

    exhibit = Exhibit.new('Panda')
    exhibit.zoo_id = zoo.id
    orm.save(exhibit)

    exhibit = orm.get(Exhibit, 0)
    assert_equal(exhibit.zoo.object_id, exhibit.zoo.object_id)
  end

  def test_belongs_to_defines_setter_on_object
    exhibit = Exhibit.new('Giraffe')
    assert_respond_to(exhibit, :zoo=)
  end

  def test_sets_child_key_when_objects_are_new
    exhibit = Exhibit.new('Buzzard')
    zoo = Zoo.new('Dallas')
    exhibit.zoo = zoo

    orm.save(exhibit)

    assert_not_nil(exhibit.zoo_id)
    assert_equal(exhibit.zoo_id, zoo.id)
  end

  def test_belongs_to_sets_association_key
    exhibit = Exhibit.new('Buzzard')
    zoo = Zoo.new('Dallas')

    orm.save(exhibit)
    orm.save(zoo)

    assert_not_blank(zoo.id, "Zoo#id must not be blank")

    exhibit.zoo = zoo
    assert_equal(zoo.id, exhibit.zoo_id)

    orm.save(exhibit)

    orm do |session|
      exhibit = session.get(Exhibit, exhibit.id)
      zoo = session.get(Zoo, zoo.id)
    end

    assert_equal(zoo.id, exhibit.zoo_id)
    assert_equal(exhibit.zoo, zoo)
  end
end