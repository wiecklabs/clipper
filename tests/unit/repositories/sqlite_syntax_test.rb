require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class SqliteSyntaxTest < Test::Unit::TestCase
  def setup
    @zoo = Class.new
    @zoos = Beacon::Mappings::Mapping.new(Beacon::Mappings.new, @zoo, "zoos")
    @zoos.key @zoos.field("id", Integer)
    @zoos.field "city", Beacon::Types::String.new(200)
  end

  def test_asdf
  end
end