module Clipper
  class Repository
    module Type
      def col_definition
        # TODO: meaningful exception
        raise Exception.new('Database column definition not set') if @col_definition.nil?
        @col_definition
      end

      def name
        @name
      end

      def name=(name)
        @name = name
      end
    end
  end
end