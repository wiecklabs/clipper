require 'benchmark'
require 'pathname'
require 'rubygems'

ORM = ARGV.first || "worm"
ADAPTER = ENV["ADAPTER"] || "sqlite"

if ORM == "dm"
  gem "dm-core"
  require "dm-core"
else
  require 'java'
  $CLASSPATH << File.dirname(__FILE__)
  require Pathname(__FILE__).dirname.parent + "lib" + "clipper"
end

gem 'faker', '~>0.3.1'
require 'faker'

if ORM == "dm"
  class Person
    include DataMapper::Resource

    property :id, Serial
    property :name, String
    property :gpa, Clipper::Types::Float(7, 2)
  end

  case ADAPTER
  when "sqlite" then DataMapper.setup(:default, "sqlite3::memory:")
  when "mysql" then DataMapper.setup(:default, "mysql://localhost/dm_worm_performance")
  end
  Person.auto_migrate!
else
  case ADAPTER
  when "sqlite" then Clipper::open("default", "jdbc:hsqldb:mem:test")
  when "mysql" then Clipper::open("default", "jdbc:mysql://localhost:3306/dm_worm_performance?user=root")
  end

  class Person
    Clipper::Mappings["default"].map(self, "people") do |people|
      people.key people.field("id", Clipper::Types::Serial)
      people.field("name", String)
      people.field("gpa", Clipper::Types::Float(7, 2))
    end
  end

  schema = Clipper::Schema.new("default")
  schema.destroy(Person) rescue nil
  schema.create(Person)
end

TIMES = ENV['x'] ? ENV['x'].to_i : 1000

puts "You can specify how many times you want to run the benchmarks with rake:perf x=(number)"
puts "Some tasks will be run 10 and 1000 times less than (number)"
puts "Benchmarks will now run #{TIMES} times"

Benchmark.bmbm do |x|

  x.report("#{ORM} #{ADAPTER} create x #{TIMES}") do
    person = proc do
      p = Person.new
      p.name = Faker::Name.name
      p.gpa = "#{rand(4)}.#{rand(9)}".to_f
      p
    end

    if ORM == "dm"
      1.upto(TIMES) { person[].save }
    else
      orm { |session| 1.upto(TIMES) { session.save(person[]) } }
    end
  end

  x.report("#{ORM} #{ADAPTER} batch create #{TIMES} records") do
    people = (1..TIMES).map do
      person = Person.new
      person.name = Faker::Name.name
      person.gpa = "#{rand(4)}.#{rand(9)}".to_f
      person
    end

    if ORM == "dm"
      repository.create(people)
    else
      orm.save(Clipper::Collection.new(Clipper::Mappings["default"].mappings[Person], people))
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

  x.report("#{ORM} #{ADAPTER} all(id < 10) x #{TIMES}") do
    if ORM == "dm"
      1.upto(TIMES) { Person.all(:id.lt => 10).entries }
    else
      conditions = Clipper::Query::Condition.lt(Clipper::Mappings["default"].mappings[Person]["id"], 10)
      orm { |session| 1.upto(TIMES) { session.all(Person, conditions) } }
    end
  end
end