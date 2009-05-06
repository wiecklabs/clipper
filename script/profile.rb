Clipper::open("default", "jdbc:hsqldb:mem:test")

TIMES = (ENV["x"] || 500).to_i

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

session = orm

people = Clipper::Collection.new(session.mappings[Person], (1..TIMES).map do
  person = Person.new
  person.name = "John Doe"
  person.gpa = "#{rand(4)}.#{rand(9)}".to_f
  person
end)

session.create(people)

1.upto(TIMES) do |i|
  session.get(Person, i)
end