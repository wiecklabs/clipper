require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"
require Pathname(__FILE__).dirname + "sample_models"

class Integration::SessionTest < Test::Unit::TestCase

  include Clipper::Session::Helper
  include Integration::SampleModels

  def setup
    Clipper::open("default", "jdbc:hsqldb:mem:test")

    @schema = Clipper::Schema.new("default")
    @schema.create(City)
  end

  def teardown
    @schema.destroy(City)
    Clipper::close("default")
  end

  def test_session_save_should_return_session
    zoo = City.new('Dallas')
    assert_kind_of(Clipper::Session, orm.save(zoo))
  end

  def test_session_save_should_update_existing_data
    # Save a new instance
    zoo = City.new('Dallas')
    orm.save(zoo)

    # Get the newly saved instance, update it
    zoo = orm.get(City, zoo.id)
    zoo.name = "Frisco"
    orm.save(zoo)

    # Get the updated instance, test to make sure the update happened
    zoo = orm.get(City, zoo.id)
    assert_equal("Frisco", zoo.name)
  end

  def test_items_retrieved_by_get_should_be_stored
    zoo = City.new('Dallas')
    orm.save(zoo)

    assert(orm.stored?(orm.get(City, zoo.id)))
  end

  def test_items_retrieved_by_all_should_be_stored
    zoo = City.new('Dallas')
    orm.save(zoo)

    assert(orm.stored?(orm.all(City).first))
  end

  def test_items_retrieved_by_find_should_be_stored
    zoo = City.new('Dallas')
    orm.save(zoo)

    dallas_zoo = Clipper::Query::Condition.eq(Clipper::Mappings["default"][City]["name"], "Dallas")

    assert(orm.stored?(orm.find(City, nil, dallas_zoo).first))
  end

end