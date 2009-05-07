require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::SessionTest < Test::Unit::TestCase

  include Clipper::Session::Helper

  class Zoo
    include Clipper::Model
    orm.map(self, "zoos") do |zoos|
      zoos.key(zoos.field("id", Clipper::Types::Serial))
      zoos.field("name", Clipper::Types::String.new(200))
    end
  end

  def setup
    Clipper::open("default", "jdbc:hsqldb:mem:test")

    @schema = Clipper::Schema.new("default")
    @schema.create(Zoo)
  end

  def teardown
    @schema.destroy(Zoo)
    Clipper::close("default")
  end

  # def test_session_save_should_return_true
  #   zoo = Zoo.new
  #   zoo.name = "Dallas"
  #   assert(orm.save(zoo))
  # end

  def test_session_save_should_update_existing_data
    # Save a new instance
    zoo = Zoo.new
    zoo.name = "Dallas"
    orm.save(zoo)

    # Get the newly saved instance, update it
    zoo = orm.get(Zoo, zoo.id)
    zoo.name = "Frisco"
    orm.save(zoo)

    # Get the updated instance, test to make sure the update happened
    zoo = orm.get(Zoo, zoo.id)
    assert_equal("Frisco", zoo.name)
  end

end