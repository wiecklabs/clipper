require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"
require Pathname(__FILE__).dirname + "sample_models"

class BelongsToTest < Test::Unit::TestCase

  include Clipper::Session::Helper
  include Integration::SampleModels

  def setup
    Clipper::open("default", "jdbc:hsqldb:mem:test")

    @schema = Clipper::Schema.new("default")
    @schema.create(Zoo)
    @schema.create(Exhibit)

    zoo = Zoo.new
    zoo.name = "Dallas Zoo"
    orm.save(zoo)

    exhibit = Exhibit.new('Zebra')
    exhibit.zoo_id = zoo.id
    orm.save(exhibit)
  end

  def teardown
    @schema.destroy(Zoo)
    @schema.destroy(Exhibit)
    Clipper::close("default")
  end

  def test_has_many_defines_getter_on_object
    zoo = Zoo.new
    assert_respond_to(zoo, :exhibits)
  end

  def test_has_many_method_returns_associated_object_collection
    zoo = orm.get(Zoo, 0)
    assert_kind_of(Clipper::Collection, zoo.exhibits)
    assert_equal(1, zoo.exhibits.size)
  end

  def test_has_many_getter_returns_same_collection
    zoo = orm.get(Zoo, 0)
    assert_equal(zoo.exhibits.object_id, zoo.exhibits.object_id)
  end

  # def test_saving_parent_instance_saves_has_many_associations
  #   zoo = orm.get(Zoo, 0)
  #   zoo.exhibits << Exhibit.new('Monkey')
  #   zoo.save
  # 
  #   zoo = orm.get(Zoo, 0)
  #   assert_equal(2, zoo.exhibits.size)
  # end

end