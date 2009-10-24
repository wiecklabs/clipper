require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"
require Pathname(__FILE__).dirname.parent + "sample_models"

class Integration::OneToManyTest < Test::Unit::TestCase
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
      orm.repository.mappings[Zoo].one_to_many(:exhibits, Exhibit) do |zoos, exhibit|
        exhibit.zoo_id.eq(zoo.id)
      end
    end

  end

  def test_each_to_enlist_yields_added_objects
    zoo = Zoo.new('Dallas')
    monkey = Exhibit.new('Zebra')
    platypus = Exhibit.new('Platypus')
    zoo.exhibits << monkey
    zoo.exhibits << platypus

    monkey_found = platypus_found = false
    zoo.exhibits.each_to_enlist do |object|
      if !monkey_found and object === monkey
        monkey_found = true
      end
      if !platypus_found and object === platypus
        platypus_found = true
      end
    end

    assert(monkey_found)
    assert(platypus_found)
  end

  def test_each_to_enlist_yields_setted_objects
    zoo = Zoo.new('Dallas')
    monkey = Exhibit.new('Zebra')
    platypus = Exhibit.new('Platypus')
    zoo.exhibits = [monkey, platypus]

    monkey_found = platypus_found = false
    zoo.exhibits.each_to_enlist do |object|
      if !monkey_found and object === monkey
        monkey_found = true
      end
      if !platypus_found and object === platypus
        platypus_found = true
      end
    end

    assert(monkey_found)
    assert(platypus_found)
  end

  def test_each_to_enlist_does_not_yield_loaded_objects
    zoo = Zoo.new('Dallas')
    monkey = Exhibit.new('Zebra')
    platypus = Exhibit.new('Platypus')
    zoo.exhibits = [monkey, platypus]
    orm.save(zoo)

    zoo = orm.get(Zoo, 0)
    monkey_found = platypus_found = false
    zoo.exhibits.each_to_enlist do |object|
      if !monkey_found and object === monkey
        monkey_found = true
      end
      if !platypus_found and object === platypus
        platypus_found = true
      end
    end

    assert(!monkey_found)
    assert(!platypus_found)
  end

  def test_each_to_enlist_works_with_loaded_and_new_objects
    zoo = Zoo.new('Dallas')
    monkey = Exhibit.new('Zebra')
    platypus = Exhibit.new('Platypus')
    zoo.exhibits = [monkey]
    orm.save(zoo)

    zoo = orm.get(Zoo, 0)
    zoo.exhibits << platypus
    monkey_found = platypus_found = false
    zoo.exhibits.each_to_enlist do |object|
      if !monkey_found and object === monkey
        monkey_found = true
      end
      if !platypus_found and object === platypus
        platypus_found = true
      end
    end

    assert(!monkey_found)
    assert(platypus_found)
  end

  def test_saving_all_new_objects
    orm do |session|
      zoo = Zoo.new('Dallas')
      zoo.exhibits << Exhibit.new('Sample')

      session << zoo
    end

    zoo = orm.get(Zoo, 0)

    assert_equal(1, orm.all(Zoo).size)
    assert_equal(1, orm.all(Exhibit).size)
    assert_equal(1, zoo.exhibits.size)
  end

  def test_saving_stored_parent_and_new_children
    zoo = Zoo.new('Dallas')
    orm.save(zoo)

    orm do |session|
      session << zoo

      zoo.exhibits << Exhibit.new('Rat')
      zoo.exhibits << Exhibit.new('Dog')
    end

    zoo = orm.get(Zoo, zoo.id)

    assert_equal(1, orm.all(Zoo).size)
    assert_equal(2, orm.all(Exhibit).size)
    assert_equal(2, zoo.exhibits.size)
  end

  def test_saving_old_parent_and_old_children
    zoo = Zoo.new('Dallas')
    orm.save(zoo)

    zoo = orm.get(Zoo, zoo.id)
    e1 = Exhibit.new('Rat')
    e2 = Exhibit.new('Dog')
    orm.save(e1)
    orm.save(e2)

    zoo.exhibits << e1
    zoo.exhibits << e2

    assert_equal(1, orm.all(Zoo).size)
    assert_equal(2, orm.all(Exhibit).size)
    assert_equal(2, zoo.exhibits.size)
  end

  def test_has_many_method_returns_associated_object_collection
    zoo = Zoo.new('Dallas')
    orm.save(zoo)

    exhibit = Exhibit.new('Zebra')
    exhibit.zoo_id = zoo.id
    orm.save(exhibit)

    zoo = orm.get(Zoo, 0)
    assert_kind_of(Clipper::Collection, zoo.exhibits)
    assert_equal(1, zoo.exhibits.size)
  end

  def test_has_many_getter_returns_same_collection
    zoo = Zoo.new('Dallas')
    orm.save(zoo)

    zoo = orm.get(Zoo, 0)
    assert_equal(zoo.exhibits.object_id, zoo.exhibits.object_id)
  end

  def test_setter_accepts_array_of_new_objects
    zoo = Zoo.new('Dallas')
    zoo.exhibits = [Exhibit.new('Bat'), Exhibit.new('Yak'), Exhibit.new('Rhino')]
    orm.save(zoo)

    zoo = orm.get(Zoo, zoo.id)

    assert_equal(3, zoo.exhibits.size)
  end

  def test_setter_clears_existing_associations
    zoo = Zoo.new('Dallas')
    zoo.exhibits = [Exhibit.new('Bat'), Exhibit.new('Yak'), Exhibit.new('Rhino')]
    orm.save(zoo)
    
    zoo = orm.get(Zoo, 0)
    zoo.exhibits = [Exhibit.new('Snake')]

    # don't need to do this since session will get flushed after setting array
    #orm.save(zoo)

    zoo = orm.get(Zoo, 0)
    assert_equal(1, zoo.exhibits.size)
    assert_equal(4, orm.all(Exhibit).size)
  end

  def test_clears_to_enlist_after_saving
    zoo = Zoo.new('Dallas')
    zoo.exhibits << Exhibit.new('Sample')
    orm.save(zoo)

    zoo.exhibits.each_to_enlist do |object|
      fail('collection not cleared')
    end
    assert(true)
  end
end