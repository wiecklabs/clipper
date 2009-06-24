require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class ModelTest < Test::Unit::TestCase

  def test_including_model_includes_accessors
    assert(Clipper::Accessors > Class.new { include Clipper::Model })
  end

  def test_including_model_includes_validations
    assert(Clipper::Validations > Class.new { include Clipper::Validations })
  end

end