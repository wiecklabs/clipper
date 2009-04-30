module Beacon
  module Repositories

    autoload :Jdbc, (Pathname(__FILE__).dirname + "repositories" + "jdbc.rb").to_s

    # STUBBED OUT...
    def self.register(name, uri)
      uri = Beacon::Uri.new(uri)
      registrations[name] = uri.driver.new(name, uri)
    end

    def self.registrations
      @repositories ||= {}
    end

  end # module Repositories
end # module Beacon