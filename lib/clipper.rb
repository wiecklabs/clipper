require "pathname"
require "set"
require "test/unit"
require "rubygems"

require Pathname(__FILE__).dirname + "vendor" + "log4j-1.2.15.jar"

require Pathname(__FILE__).dirname + "wieck" + "assertions"
require Pathname(__FILE__).dirname + "wieck" + "blank"
require Pathname(__FILE__).dirname + "wieck" + "using"
require Pathname(__FILE__).dirname + "wieck" + "string"

# require Pathname(__FILE__).dirname.parent + "clipper_internal.jar"


require Pathname(__FILE__).dirname + "clipper" + "uri"

require Pathname(__FILE__).dirname + "clipper" + "model"

require Pathname(__FILE__).dirname + "clipper" + "accessors"

require Pathname(__FILE__).dirname + "clipper" + "hooks"

require Pathname(__FILE__).dirname + "clipper" + "type"
require Pathname(__FILE__).dirname + "clipper" + "types"
require Pathname(__FILE__).dirname + "clipper" + "mappings" + "mapping"
require Pathname(__FILE__).dirname + "clipper" + "mappings" + "relation"

require Pathname(__FILE__).dirname + "clipper" + "validations"
require Pathname(__FILE__).dirname + "clipper" + "validations" + "validator"
require Pathname(__FILE__).dirname + "clipper" + "validations" + "context"
require Pathname(__FILE__).dirname + "clipper" + "validations" + "validation_result"
require Pathname(__FILE__).dirname + "clipper" + "validations" + "validation_error"
require Pathname(__FILE__).dirname + "clipper" + "validations" + "absence_validator"
require Pathname(__FILE__).dirname + "clipper" + "validations" + "acceptance_validator"
require Pathname(__FILE__).dirname + "clipper" + "validations" + "minimum_length_validator"
require Pathname(__FILE__).dirname + "clipper" + "validations" + "maximum_length_validator"
require Pathname(__FILE__).dirname + "clipper" + "validations" + "within_validator"
require Pathname(__FILE__).dirname + "clipper" + "validations" + "size_validator"
require Pathname(__FILE__).dirname + "clipper" + "validations" + "required_validator"
require Pathname(__FILE__).dirname + "clipper" + "validations" + "format_validator"
require Pathname(__FILE__).dirname + "clipper" + "validations" + "equality_validator"

require Pathname(__FILE__).dirname + "clipper" + "repositories"
require Pathname(__FILE__).dirname + "clipper" + "repositories" + "schema"
require Pathname(__FILE__).dirname + "clipper" + "repositories" + "abstract"

require Pathname(__FILE__).dirname + "clipper" + "query" + "query"
require Pathname(__FILE__).dirname + "clipper" + "query" + "expression"
require Pathname(__FILE__).dirname + "clipper" + "query" + "condition"
require Pathname(__FILE__).dirname + "clipper" + "query" + "criteria"

require Pathname(__FILE__).dirname + "clipper" + "syntax" + "sql"

require Pathname(__FILE__).dirname + "clipper" + "session"
require Pathname(__FILE__).dirname + "clipper" + "collection"
require Pathname(__FILE__).dirname + "clipper" + "identity_map"
require Pathname(__FILE__).dirname + "clipper" + "mappings"
require Pathname(__FILE__).dirname + "clipper" + "schema"
require Pathname(__FILE__).dirname + "clipper" + "session" + "helper"

module Clipper

  @registrations = {}
  def self.registrations
    @registrations
  end

  def self.open(connection_name, uri)
    uri = Clipper::Uri.new(uri)
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