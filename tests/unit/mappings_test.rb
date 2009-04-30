require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class MappingsTest < Test::Unit::TestCase

  def test_indexer_raises_error_for_unmapped_class
    mappings = Beacon::Mappings.new
    assert_raise(Beacon::Mappings::UnmappedClassError) { mappings[Class.new] }
  end

  def test_can_assign_a_mapping
    mappings = Beacon::Mappings.new
    assert_nothing_raised do
      cow = Class.new
      mapping = Beacon::Mappings::Mapping.new(Beacon::Mappings.new, cow, "cows")
      mappings << mapping
      assert_equal(mapping, mappings[cow])
    end
  end

  def test_assigning_non_mapping
    mappings = Beacon::Mappings.new

    assert_raise(ArgumentError) { mappings << nil }
  end

  def test_mappings_should_be_enumerable
    mappings = Beacon::Mappings.new

    assert_respond_to(mappings, :each)
    assert_kind_of(Enumerable, mappings)

    cows = Beacon::Mappings::Mapping.new(Beacon::Mappings.new, Class.new, 'cows')
    pigs = Beacon::Mappings::Mapping.new(Beacon::Mappings.new, Class.new, 'pigs')

    mappings << cows
    mappings << pigs

    mappings.each { |m| assert([cows, pigs].include?(m), "#{m} isn't one of: #{cows}, #{pigs}") }
  end

end