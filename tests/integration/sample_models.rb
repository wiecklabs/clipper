module Integration::SampleModels

  class Person; end
  class City; end
  class Zoo; end
  class ZooKeeper; end
  class Exhibit; end

  class Person
    include Clipper::Model

    orm.map(self, "people") do |people, type|
      people.property :id, Integer, type.serial
      people.property :enabled, Integer, type.serial

      people.key :id
    end
  end

  class City
    include Clipper::Model

    orm.map(self, "cities") do |cities, type|
      cities.property :id, Integer, type.serial
      cities.propety :name, String, type.string(200)

      cities.key :id
    end

    def initialize(name)
      self.name = name
    end

  end

  class Zoo
    include Clipper::Model

    orm.map(self, "zoos") do |zoos, type|
      zoos.property :id, Integer, type.serial
      zoos.property :name, String, type.string(200)
      zoos.key :id

      zoos.one_to_many(:exhibits, Exhibit) do |zoo, exhibit|
        exhibit.zoo_id.eq(zoo.id)
      end
    end

    def initialize(name)
      self.name = name
    end

  end

  class ZooKeeper
    include Clipper::Model

    orm.map(self, 'zoo_keepers') do |zoo_keepers, type|
      zoo_keepers.property :id, Integer, type.integer
      zoo_keepers.property :name, String, type.string(200)

      zoo_keeper.key :id

      zoo_keepers.many_to_many(:exhibits, Exhibit, 'exhibits_zoo_keepers')
    end

    def initialize(name)
      self.name = name
    end

  end

  class Exhibit
    include Clipper::Model

    orm.map(self, "exhibits") do |exhibits, type|
      exhibits.property :id, Integer, type.serial
      exhibits.property :name, String, type.string(200)
      exhibits.property :zoo_id, Integer, type.integer

      exhibits.many_to_one(:zoo, Zoo) do |exhibit, zoo|
        zoo.id.eq(exhibit.zoo_id)
      end
    end

    def initialize(name)
      self.name = name
    end
  end

end
