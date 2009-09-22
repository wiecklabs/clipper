module Clipper
  class Session
    module Helper
      def orm(repository_name = "default", &block)
        Helper.orm(repository_name, &block)
      end

      def self.orm(repository_name = "default", &block)
        session = Clipper::Session.new(repository_name, !block)
        if block
          block.call(session)
          session.flush
        else
          session
        end
      end
    end
  end
end