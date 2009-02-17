require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class BelongsToTest < Test::Unit::TestCase
  def setup
    @uri = Wheels::Orm::Uri.new("jdbc:hsqldb:mem:test")
    Wheels::Orm::Repositories::register("default", @uri.to_s)

    @zoo = Class.new
    orm.map(@zoo, "zoos") do |zoos|
      zoos.key(zoos.field("id", Wheels::Orm::Types::Serial))
    end

    @exhibit = Class.new
    orm.map(@exhibit, "exhibits") do |exhibits|
      exhibits.key(exhibits.field("id", Wheels::Orm::Types::Serial))
      exhibits.field("zoo_id", Integer)
      exhibits.proxy("zoo") { |exhibit| orm.mappings[@zoo]["id"].eq(exhibit.zoo_id) }
    end

    @schema = Wheels::Orm::Schema.new("default")
    @schema.create(@zoo)
    @schema.create(@exhibit)

    zoo = @zoo.new
    orm.save(zoo)

    exhibit = @exhibit.new
    exhibit.zoo_id = zoo.id
    orm.save(exhibit)
  end

  def test_proxy_defines_getter_on_object
    exhibit = @exhibit.new
    assert_respond_to(exhibit, :zoo)
  end

  def test_proxy_method_returns_associated_object
    exhibit = orm.get(@exhibit, 0)
    assert_kind_of(@zoo, exhibit.zoo)
    assert_equal(0, exhibit.zoo.id)
  end

  def test_proxy_defines_setter_on_object
    exhibit = @exhibit.new
    assert_respond_to(exhibit, :zoo=)
  end

  def test_proxy_sets_association_key
    exhibit = @exhibit.new
    orm.save(zoo = @zoo.new)
    exhibit.zoo = zoo
    assert_equal(zoo.id, exhibit.zoo_id)
  end

  def teardown
    @schema.destroy(@zoo)
    @schema.destroy(@exhibit)
    Wheels::Orm::Repositories::registrations.delete("default")
  end
end