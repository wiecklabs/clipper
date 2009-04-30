require "pathname"
require "test/unit"
require "java"

$CLASSPATH << File.dirname(__FILE__)

require Pathname(__FILE__).dirname.parent + "lib" + "beacon"

module Integration
end