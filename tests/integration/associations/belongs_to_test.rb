require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class BelongsToTest < Test::Unit::TestCase

  include Clipper::Session::Helper

  class Zoo
    include Clipper::Model

    orm.map(self, "zoos") do |zoos|
      zoos.key(zoos.field("id", Clipper::Types::Serial))
    end
  end

  class Exhibit
    include Clipper::Model

    orm.map(self, "exhibits") do |exhibits|
      exhibits.key(exhibits.field("id", Clipper::Types::Serial))
      exhibits.field("zoo_id", Clipper::Types::Integer)

      exhibits.belong_to('zoo', Zoo) do |exhibit, zoo|
        zoo.id.eq(exhibit.zoo_id)
      end
    end
  end

  def setup
    Clipper::open("default", "jdbc:hsqldb:mem:test")

    @schema = Clipper::Schema.new("default")
    @schema.create(Zoo)
    @schema.create(Exhibit)

    zoo = Zoo.new
    orm.save(zoo)

    exhibit = Exhibit.new
    exhibit.zoo_id = zoo.id
    orm.save(exhibit)
  end

  def teardown
    @schema.destroy(Zoo)
    @schema.destroy(Exhibit)
    Clipper::close("default")
  end

  def test_belongs_to_defines_getter_on_object
    exhibit = Exhibit.new
    assert_respond_to(exhibit, :zoo)
  end

  def test_belongs_to_method_returns_associated_object
    exhibit = orm.get(Exhibit, 0)
    assert_kind_of(Zoo, exhibit.zoo)
    assert_equal(0, exhibit.zoo.id)
  end

  def test_has_many_getter_returns_same_instance
    exhibit = orm.get(Exhibit, 0)
    assert_equal(exhibit.zoo.object_id, exhibit.zoo.object_id)
  end

  def test_belongs_to_defines_setter_on_object
    exhibit = Exhibit.new
    assert_respond_to(exhibit, :zoo=)
  end

  def test_belongs_to_sets_association_key
    exhibit = Exhibit.new
    orm.save(zoo = Zoo.new)
    assert_not_blank(zoo.id, "Zoo#id must not be blank")
    exhibit.zoo = zoo
    assert_equal(zoo.id, exhibit.zoo_id)
    orm.save(exhibit)

    exhibit = orm.get(Exhibit, exhibit.id)
    assert_not_nil(exhibit.zoo)
    assert_equal(exhibit.zoo, zoo)
  end
end