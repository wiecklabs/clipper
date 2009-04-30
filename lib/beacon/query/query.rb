module Beacon
  class Query
    def initialize(mapping, options, conditions)
      @mapping = mapping
      @conditions = conditions
      
      if options
        @limit = options.fetch(:limit, nil)
        @offset = options.fetch(:offset, nil)
        @order = options.fetch(:order, nil)
      end
    end

    def mapping
      @mapping
    end

    def limit
      @limit
    end
    
    def offset
      @offset
    end
    
    def order
      @order
    end
    
    def conditions
      @conditions
    end

    def paramaters
      case @conditions
      when nil then []
      when Condition then [@conditions.value]
      else
        begin
          @conditions.values.map { |condition| condition.value }
        rescue NoMethodError => nme
          p @conditions
          raise
        end
      end
    end

    def fields
      case @conditions
      when nil then []
      when Condition then [@conditions.field]
      else
        @conditions.values.map { |condition| condition.field }
      end
    end
  end
end