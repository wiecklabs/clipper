require "pathname"
require "test/unit"
require "java"

$CLASSPATH << File.dirname(__FILE__)

require Pathname(__FILE__).dirname.parent + "lib" + "clipper"

adapters = ENV["ADAPTERS"] || "hsqldb, mysql, sqlite"
ADAPTERS = adapters.split(/,\s*/)

module Integration
end