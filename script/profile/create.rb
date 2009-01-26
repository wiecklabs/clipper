require File.dirname(__FILE__) + "/setup"
require "profile"

orm do |session|
  TIMES.times do
    person = Person.new
    person.name = "John"
    person.gpa = "#{rand(4)}.#{rand(9)}".to_f
    session.save(person)
  end
end