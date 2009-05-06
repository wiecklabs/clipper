require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::SessionTest < Test::Unit::TestCase

  include Clipper::Session::Helper

  class Zoo
    include Clipper::Model
    orm.map(self, "zoos") do |zoos|
      zoos.key "id", Integer
      zoos.field "name", Clipper::Types::String.new(200)
    end
  end

  def setup
    Clipper::open("default", "abstract://localhost/example")
  end

  def teardown
    Clipper::registrations.delete("default")
  end

  def test_session_save_should_return_true
    zoo = Zoo.new
    zoo.name = "Dallas"
    assert(orm.save(zoo))
  end
end