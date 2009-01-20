module Wheels
  module Orm
    module Repositories

      # STUBBED OUT...
      def self.register(name, uri)
        uri = Wheels::Orm::Uri.new(uri)
        registrations[name] = uri.driver.new(name, uri)
      end

      def self.registrations
        @repositories ||= {}
      end

    end # module Repositories
  end # module Orm
end # module Wheels