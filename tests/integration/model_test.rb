require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::ModelTest < Test::Unit::TestCase

  include Clipper::Session::Helper

  class Zoo
    include Clipper::Model

    orm.map(self, "zoos") do |zoos|
      zoos.key "id", Integer
      zoos.field "name", Clipper::Types::String.new(200)
    end
  end

  def setup
    Clipper.open("default", "jdbc:hsqldb://#{Pathname(__FILE__).dirname.expand_path + "sqlite.db"}")
  end

  def teardown
    Clipper.close("default")
  end

  def test_new_record
    assert(!(orm.stored? Zoo.new))
  end

end