require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class AbstractRepositoryTest < Test::Unit::TestCase

  def test_initialize_with_proper_arguments
    assert_nothing_raised do
      uri = Clipper::Uri.new("abstract://localhost/example")
      Clipper::Repositories::Abstract.new("abstract", uri)
    end
  end

  def test_initialize_with_improper_arguments
    assert_raises(ArgumentError) do
      uri = Clipper::Uri.new("abstract://localhost/example")
      Clipper::Repositories::Abstract.new(nil, uri)
    end

    assert_raises(ArgumentError) do
      uri = Clipper::Uri.new("abstract://localhost/example")
      Clipper::Repositories::Abstract.new("", uri)
    end

    assert_raises(ArgumentError) do
      Clipper::Repositories::Abstract.new("abstract", "abstract://localhost/example")
    end
  end

  def test_type_map
    assert_nothing_raised do
      map = Clipper::Repositories::Abstract.type_map
      assert(map.is_a?(Clipper::TypeMap))
    end
  end

end