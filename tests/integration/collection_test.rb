require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::CollectionTest < Test::Unit::TestCase

  include Clipper::Session::Helper

  def setup
    @uri = Clipper::Uri.new("jdbc:hsqldb:mem:test")
    Clipper::open("default", @uri.to_s)

    type_map = Clipper::registrations['default'].class.type_map
    type_map << Clipper::TypeMap::Signature.new(
      [Integer],
      [Clipper::Repositories::Types::Hsqldb::Serial],
      lambda { |value| value.to_i },
      lambda { |value| value }
    )

    @person = Class.new do
      include Clipper::Model

      accessor :id => Integer

      orm.map(self, "people") do |people, type|
        people.field :id, type.serial
        people.key :id
      end
    end

    @mapping = orm.repository.mappings[@person]
  end

  def teardown
    Clipper::close("default")
  end

  def test_should_have_an_indexer
    assert_equal(1, Clipper::Collection.new(@mapping, [1])[0])
  end
end