require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::CriteriaTest < Test::Unit::TestCase

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

  def test_options_do_not_have_side_effects_on_conditions
    people = Clipper::Query::Criteria.new(@mapping)
    assert_nothing_raised do
      people.limit 3
      people.order(people.gpa.desc, people.name)
    end

    assert_equal({ :limit => 3, :order => [[@mapping["gpa"], :desc], [@mapping["name"], :asc]] }, people.__options__)
    assert_nil(people.__conditions__)
  end
end