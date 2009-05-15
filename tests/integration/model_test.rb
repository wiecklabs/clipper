require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"
require Pathname(__FILE__).dirname + "sample_models"

class Integration::ModelTest < Test::Unit::TestCase

  include Clipper::Session::Helper
  include Integration::SampleModels

  def setup
    Clipper.open("default", "jdbc:hsqldb://#{Pathname(__FILE__).dirname.expand_path + "sqlite.db"}")
  end

  def teardown
    Clipper.close("default")
  end

  def test_new_record
    assert(!(orm.stored? City.new('Dallas')))
  end

end