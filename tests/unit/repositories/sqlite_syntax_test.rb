require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class SqliteSyntaxTest < Test::Unit::TestCase
  def setup
    @zoo = Class.new
    @zoos = Wheels::Orm::Mappings::Mapping.new(@zoo, "zoos")
    @zoos.key @zoos.field("id", Integer)
    @zoos.field "city", Wheels::Orm::Types::String.new(200)
  end

  def test_asdf
  end
end