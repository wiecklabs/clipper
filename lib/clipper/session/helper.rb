module Clipper
  class Session
    module Helper
      def orm(repository_name = "default")
        session = Clipper::Session.new(repository_name, !block_given?)
        if block_given?
          yield session
          session.flush
        else
          session
        end
      end
    end
  end
end