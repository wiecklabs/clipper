require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class MappingTest < Test::Unit::TestCase
  def test_mapping_has_a_target
    mapping = Wheels::Orm::Mappings::Mapping.new(Wheels::Orm::Mappings.new, Class.new, "mappings")
    assert_respond_to(mapping, :target)
  end
end