##
# creates mapping for default repository
##

orm = Clipper::Session::Helper.orm('default')

orm.map(Integration::SampleModels::Person, "people") do |people, type|
  people.field :id, type.serial
  people.field :enabled, type.serial

  people.key :id
end

orm.map(Integration::SampleModels::City, "cities") do |cities, type|
  cities.field :id, type.serial
  cities.field :name, type.string(200)

  cities.key :id
end

orm.map(Integration::SampleModels::Zoo, "zoos") do |zoos, type|
  zoos.field :id, type.serial
  zoos.field :name, type.string(200)
  zoos.key :id

  zoos.one_to_many(:exhibits, Integration::SampleModels::Exhibit) do |zoo, exhibit|
    exhibit.zoo_id.eq(zoo.id)
  end
end

orm.map(Integration::SampleModels::ZooKeeper, 'zoo_keepers') do |zoo_keepers, type|
  zoo_keepers.field :id, type.integer
  zoo_keepers.field :name, type.string(200)

  zoo_keepers.key :id

#  zoo_keepers.many_to_many(:exhibits, Integration::SampleModels::Exhibit, 'exhibits_zoo_keepers')
end

orm.map(Integration::SampleModels::Exhibit, "exhibits") do |exhibits, type|
  exhibits.field :id, type.serial
  exhibits.field :name, type.string(200)
  exhibits.field :zoo_id, type.integer

  exhibits.key :id

  exhibits.many_to_one(:zoo, Integration::SampleModels::Zoo) do |exhibit, zoo|
    zoo.id.eq(exhibit.zoo_id)
  end
end