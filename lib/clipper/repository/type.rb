module Clipper
  class Repository
    module Type
      def name
        @name
      end

      def name=(name)
        @name = name
      end
    end
  end
end