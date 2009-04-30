require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::SessionTest < Test::Unit::TestCase

  def setup
    Beacon::Repositories::register("default", "abstract://localhost/example")
    @zoo = Class.new do
      Beacon::Mappings["default"].map(self, "zoos") do |zoos|
        zoos.key "id", Integer
        zoos.field "name", Beacon::Types::String.new(200)
      end
    end
  end

  def teardown
    Beacon::Repositories::registrations.delete("default")
  end

  def test_session_save_should_return_true
    zoo = @zoo.new
    zoo.name = "Dallas"
    assert(orm.save(zoo))
  end
end