require 'benchmark'
require 'pathname'
require 'rubygems'

ORM = ARGV.first || "worm"
ADAPTER = ENV["ADAPTER"] || "sqlite"


if ORM == "dm"
  gem "dm-core"
  require "dm-core"
else
  require Pathname(__FILE__).dirname.parent + "lib" + "wheels" + "orm"
end

gem 'faker', '~>0.3.1'
require 'faker'

if ORM == "dm"
  class Person
    include DataMapper::Resource

    property :id, Serial
    property :name, String
    property :gpa, Float
  end

  case ADAPTER
  when "sqlite" then DataMapper.setup(:default, "sqlite3::memory:")
  when "mysql" then DataMapper.setup(:default, "mysql://localhost/dm_worm_performance")
  end
  Person.auto_migrate!
else
  case ADAPTER
  when "sqlite" then Wheels::Orm::Repositories.register("default", "jdbc:hsqldb:mem:test")
  when "mysql" then Wheels::Orm::Repositories.register("default", "jdbc:mysql://localhost:3306/dm_worm_performance?user=root")
  end

  class Person
    orm.map(self, "people") do |people|
      people.key people.field("id", Wheels::Orm::Types::Serial)
      people.field("name", String)
      people.field("gpa", Float)
    end
  end

  schema = Wheels::Orm::Schema.new("default")
  schema.destroy(Person) rescue nil
  schema.create(Person)
end

TIMES = ENV['x'] ? ENV['x'].to_i : 1000

puts "You can specify how many times you want to run the benchmarks with rake:perf x=(number)"
puts "Some tasks will be run 10 and 1000 times less than (number)"
puts "Benchmarks will now run #{TIMES} times"

Benchmark.bmbm do |x|
  x.report("#{ORM} #{ADAPTER} create x #{TIMES}") do
    people = (1..TIMES).map do
      person = Person.new
      person.name = Faker::Name.name
      person.gpa = "#{rand(4)}.#{rand(9)}".to_f
      person
    end

    if ORM == "dm"
      repository.create(people)
    else
      orm.save(Wheels::Orm::Collection.new(orm.mappings[Person], people))
    end
  end

  x.report("#{ORM} #{ADAPTER} get x #{TIMES}") do
    if ORM == "dm"
      1.upto(TIMES) { |i| Person.get(i) }
    else
      orm { |session| 1.upto(TIMES) { |i| session.get(Person, i) } }
    end
  end

  x.report("#{ORM} #{ADAPTER} all x #{10}") do
    if ORM == "dm"
      1.upto(10) { Person.all.entries }
    else
      orm { |session| 1.upto(10) { session.all(Person) } }
    end
  end
end