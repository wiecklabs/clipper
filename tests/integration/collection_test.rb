require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::CollectionTest < Test::Unit::TestCase

  include Clipper::Session::Helper

  def setup
    @uri = Clipper::Uri.new("abstract://localhost/example")
    Clipper::open("example", @uri.to_s)

    @person = Class.new do
      Clipper::Mappings["example"].map(self, "people") do |people|
        people.key people.field("id", Clipper::Types::Serial)
        people.field "name", Clipper::Types::String.new(200)
        people.field "gpa", Clipper::Types::Float(7, 2)
      end
    end

    @mapping = orm("example").repository.mappings[@person]
  end

  def teardown
    Clipper::close("example")
  end

  def test_should_have_an_indexer
    assert_equal(1, Clipper::Collection.new(@mapping, [1])[0])
  end
end