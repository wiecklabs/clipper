module Integration::SampleModels

  class Person; end
  class City; end
  class Zoo; end
  class ZooKeeper; end
  class Exhibit; end

  class Person
    include Clipper::Model

    accessor :id => Integer
    accessor :enabled => Integer
  end

  class City
    include Clipper::Model

    accessor :id => Integer
    accessor :name => String

    def initialize(name)
      self.name = name
    end
  end

  class Zoo
    include Clipper::Model

    accessor :id => Integer
    accessor :name => String

    def initialize(name)
      self.name = name
    end
  end

  class ZooKeeper
    include Clipper::Model

    accessor :id => Integer
    accessor :name => String

    def initialize(name)
      self.name = name
    end
  end

  class Exhibit
    include Clipper::Model

    accessor :id => Integer
    accessor :zoo_id => Integer
    accessor :name => String

    def initialize(name)
      self.name = name
    end
  end
end
