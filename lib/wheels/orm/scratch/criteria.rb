module Datos
  class Criteria
    def initialize(root, &expression)
      @root = root
      @expression = expression
    end
    
    def method_missing(sym, *args)
      if args.empty?
        Partial.new(sym)
      else
        super
      end
    end
    
    def to_a
      @expression.call(self)
    end
    
    private
    class Partial
      def initialize(name)
        @name = name
      end
      
      def method_missing(sym, *args)
        UnboundCondition.new(sym, @name, *args)
      end
    end
  end
end