require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::ModelTest < Test::Unit::TestCase

  class Zoo

  end

  def setup
    Beacon.open("default", "jdbc:sqlite://#{Pathname(__FILE__).dirname.expand_path + "sqlite.db"}")

    @zoo = Class.new do
      Beacon::Mappings["default"].map(self, "zoos") do |zoos|
        zoos.key "id", Integer
        zoos.field "name", Beacon::Types::String.new(200)
      end
    end
  end

  def teardown
    Beacon.close("default")
  end

  def test_true
    assert true
  end

end