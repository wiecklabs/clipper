module Datos
  class Query
    def initialize(root)
      @root = root
      @conditions = nil
    end

    def conditions
      @conditions
    end

    def conditions=(expression)
      @conditions = expression
    end
  end  
end