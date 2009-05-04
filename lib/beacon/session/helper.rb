module Beacon
  class Session
    module Helper
      def orm(repository_name = "default")
        session = Beacon::Session.new(repository_name)
        yield session if block_given?
        session
      end
    end
  end
end