module Integration::SampleModels

  class Zoo; end
  class Exhibit; end

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
