require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::ModelTest < Test::Unit::TestCase

  include Beacon::Session::Helper

  class Zoo
    include Beacon::Model

    orm.map(self, "zoos") do |zoos|
      zoos.key "id", Integer
      zoos.field "name", Beacon::Types::String.new(200)
    end
  end

  def setup
    Beacon.open("default", "jdbc:hsqldb://#{Pathname(__FILE__).dirname.expand_path + "sqlite.db"}")
  end

  def teardown
    Beacon.close("default")
  end

  def test_new_record
    assert(!(orm.stored? Zoo.new))
  end

end