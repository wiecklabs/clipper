module Clipper
  class Mappings

    class Association

      def mapping
        @mapping
      end

      def name
        @name
      end

      def match_criteria
        @match_criteria
      end

      def getter
        name
      end

      def setter
        "#{name}="
      end

      def get(instance)
        instance.send(self.getter)
      end

      def eql?(other)
        other.is_a?(Association) && mapping == other.mapping && name == other.name
      end
      alias == eql?

      def to_s
        "<#{self.class.name} Mapping: #{mapping.name} #{name}>"
      end

    end

  end
end