require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"

class BelongsToTest < Test::Unit::TestCase
  class Zoo
  end

  class Exhibit
  end

  def setup
    @uri = Wheels::Orm::Uri.new("jdbc:hsqldb:mem:test")
    Wheels::Orm::Repositories::register("default", @uri.to_s)

    @zoo = Zoo
    Wheels::Orm::Mappings["default"].map(@zoo, "zoos") do |zoos|
      zoos.key(zoos.field("id", Wheels::Orm::Types::Serial))
    end

    @exhibit = Exhibit
    Wheels::Orm::Mappings["default"].map(@exhibit, "exhibits") do |exhibits|
      exhibits.key(exhibits.field("id", Wheels::Orm::Types::Serial))
      exhibits.field("zoo_id", Wheels::Orm::Types::Integer)


      # Exhibit#inhabitants returns an animal or keeper:
      #
      #   Equivilant to the query:
      #   SELECT * FROM animals WHERE exhibit_id = ? AND (animals.color = 'Blue' OR animals.color = 'Dark-Blue')
      #   UNION ALL
      #   SELECT * FROM keepers WHERE exhibit_id = ?
      #
      # exhibits.have_many('inhabitants', 'animal', 'keeper') do |exhibit, animal, keeper|
      #   animal.exhibit_id.eq(exhibit.id).and(animal.color.eq('Blue').or(animal.color.eq('Dark-Blue'))).or(keeper.exhibit_id.eq(exhibit.id))
      # end

      # exhibits.have_one('keeper', 'keepers') do |exhibit, keepers|
      #   keepers.exhibit_id.eq(exhibits.id)
      # end

      exhibits.belong_to('zoo', Zoo) do |exhibit, zoo|
        zoo.id.eq(exhibit.zoo_id)
      end

      # animals.belongs_to('exhibit', 'animals') do |exhibit, animals|
      #  exhibit.ecosystem.eq(animals.ecosystem)
      # end

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
    assert_not_blank(zoo.id, "Zoo#id must not be blank")
    exhibit.zoo = zoo
    assert_equal(zoo.id, exhibit.zoo_id)
  end

  def teardown
    @schema.destroy(@zoo)
    @schema.destroy(@exhibit)
    Wheels::Orm::Repositories::registrations.delete("default")
  end
end