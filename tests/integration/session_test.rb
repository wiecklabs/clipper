require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::SessionTest < Test::Unit::TestCase

  def setup
    Wheels::Orm::Repositories::register("default", "abstract://localhost/example")
    @zoo = Class.new do
      orm.map(self, "zoos") do |zoos|
        zoos.key "id", Integer
        zoos.field "name", String
      end
    end
  end

  def teardown
    Wheels::Orm::Repositories::registrations.delete("default")
  end

  def test_session_save_should_return_true
    zoo = @zoo.new
    zoo.name = "Dallas"
    assert(orm.save(zoo))
  end
end