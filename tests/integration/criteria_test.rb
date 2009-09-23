require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::CriteriaTest < Test::Unit::TestCase
  include Clipper::Session::Helper
  
  def setup
    @uri = Clipper::Uri.new("abstract://localhost/example")
    Clipper::open("default", @uri.to_s)

    @person = Class.new do
      include Clipper::Model

      accessor :id => Integer
      accessor :name => String
      accessor :gpa => Float

      orm.map(self, "people") do |people, type|
        people.field :id, type.serial
        people.field :name, type.string(200)
        people.field :gpa, type.float

        people.key :id
      end
    end

    @mapping = orm.repository.mappings[@person]
  end

  def teardown
    Clipper::close("default")
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