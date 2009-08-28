module Integration::SampleModels

  class Person; end
  class City; end
  class Zoo; end
  class ZooKeeper; end
  class Exhibit; end
  
  class Person
    include Clipper::Accessors
    
    accessor :id => Integer
    accessor :name => String
    
    include Clipper::Model

    orm.map(self, "people") do |people|
      people.key(
        people.field("id", Clipper::Repositories::Jdbc::Postgres::Serial.new)
      )
      people.field("name", Clipper::Repositories::Jdbc::Postgres::String.new(200))
    end
  end

  class City
    include Clipper::Model

    orm.map(self, "cities") do |cities|
      cities.key(cities.field("id", Clipper::Types::Serial))
      cities.field("name", Clipper::Types::String.new(200))
    end

    def initialize(name)
      self.name = name
    end

  end

  class Zoo
    include Clipper::Model

    orm.map(self, "zoos") do |zoos|
      zoos.key(zoos.field("id", Clipper::Types::Serial))
      zoos.field("name", Clipper::Types::String.new(200))

      zoos.have_many('exhibits', Exhibit) do |zoo, exhibit|
        exhibit.zoo_id.eq(zoo.id)
      end
    end

    def initialize(name)
      self.name = name
    end

  end

  class ZooKeeper
    include Clipper::Model

    orm.map(self, 'zoo_keepers') do |zoo_keepers|
      zoo_keepers.key(zoo_keepers.field('id', Clipper::Types::Serial))
      zoo_keepers.field('name', Clipper::Types::String.new(200))

      zoo_keepers.many_to_many('exhibits', Exhibit, 'exhibits_zoo_keepers')
    end

    def initialize(name)
      self.name = name
    end

  end

  class Exhibit
    include Clipper::Model

    orm.map(self, "exhibits") do |exhibits|
      exhibits.key(exhibits.field("id", Clipper::Types::Serial))
      exhibits.field("name", Clipper::Types::String.new(200))
      exhibits.field("zoo_id", Clipper::Types::Integer)

      exhibits.belong_to('zoo', Zoo) do |exhibit, zoo|
        zoo.id.eq(exhibit.zoo_id)
      end
    end

    def initialize(name)
      self.name = name
    end
  end

end
