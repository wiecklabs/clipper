require "pathname"
require "set"
require "test/unit"
require "rubygems"

require Pathname(__FILE__).dirname + "vendor" + "log4j-1.2.15.jar"

require Pathname(__FILE__).dirname + "wieck" + "assertions"
require Pathname(__FILE__).dirname + "wieck" + "blank"
require Pathname(__FILE__).dirname + "wieck" + "using"
require Pathname(__FILE__).dirname + "wieck" + "string"

# require Pathname(__FILE__).dirname.parent + "beacon_internal.jar"


require Pathname(__FILE__).dirname + "beacon" + "uri"

require Pathname(__FILE__).dirname + "beacon" + "model"

require Pathname(__FILE__).dirname + "beacon" + "accessors"

require Pathname(__FILE__).dirname + "beacon" + "hooks"

require Pathname(__FILE__).dirname + "beacon" + "type"
require Pathname(__FILE__).dirname + "beacon" + "types"
require Pathname(__FILE__).dirname + "beacon" + "mappings" + "mapping"
require Pathname(__FILE__).dirname + "beacon" + "mappings" + "relation"

require Pathname(__FILE__).dirname + "beacon" + "validations"
require Pathname(__FILE__).dirname + "beacon" + "validations" + "validator"
require Pathname(__FILE__).dirname + "beacon" + "validations" + "context"
require Pathname(__FILE__).dirname + "beacon" + "validations" + "validation_result"
require Pathname(__FILE__).dirname + "beacon" + "validations" + "validation_error"
require Pathname(__FILE__).dirname + "beacon" + "validations" + "absence_validator"
require Pathname(__FILE__).dirname + "beacon" + "validations" + "acceptance_validator"
require Pathname(__FILE__).dirname + "beacon" + "validations" + "minimum_length_validator"
require Pathname(__FILE__).dirname + "beacon" + "validations" + "maximum_length_validator"
require Pathname(__FILE__).dirname + "beacon" + "validations" + "within_validator"
require Pathname(__FILE__).dirname + "beacon" + "validations" + "size_validator"
require Pathname(__FILE__).dirname + "beacon" + "validations" + "required_validator"
require Pathname(__FILE__).dirname + "beacon" + "validations" + "format_validator"
require Pathname(__FILE__).dirname + "beacon" + "validations" + "equality_validator"

require Pathname(__FILE__).dirname + "beacon" + "repositories"
require Pathname(__FILE__).dirname + "beacon" + "repositories" + "schema"
require Pathname(__FILE__).dirname + "beacon" + "repositories" + "abstract"

require Pathname(__FILE__).dirname + "beacon" + "query" + "query"
require Pathname(__FILE__).dirname + "beacon" + "query" + "expression"
require Pathname(__FILE__).dirname + "beacon" + "query" + "condition"
require Pathname(__FILE__).dirname + "beacon" + "query" + "criteria"

require Pathname(__FILE__).dirname + "beacon" + "syntax" + "sql"

require Pathname(__FILE__).dirname + "beacon" + "session"
require Pathname(__FILE__).dirname + "beacon" + "collection"
require Pathname(__FILE__).dirname + "beacon" + "identity_map"
require Pathname(__FILE__).dirname + "beacon" + "mappings"
require Pathname(__FILE__).dirname + "beacon" + "schema"
require Pathname(__FILE__).dirname + "beacon" + "session" + "helper"

module Beacon

  @registrations = {}
  def self.registrations
    @registrations
  end

  def self.open(connection_name, uri)
    uri = Beacon::Uri.new(uri)
    @registrations[connection_name] = uri.driver.new(connection_name, uri)
  end

  def self.close(connection_name)
    if driver = @registrations.delete(connection_name)
      driver.close
    else
      raise ArgumentError.new("#{connection_name.inspect} is not a registered connection.")
    end
  end
end