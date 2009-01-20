module Datos
  module Syntax

    def self.serialize(sexp)
      send(*sexp)
    end

    private
    def self.and(*args)
      "(" + args.map do |expr|
        send(*expr)
      end.join(" AND ") + ")"
    end

    def self.or(*args)
      "(" + args.map do |expr|
        send(*expr)
      end.join(" OR ") + ")"
    end

    def self.gt(field, value)
      "#{field} > #{value}"
    end

    def self.lt(field, value)
      "#{field} < #{value}"
    end

    def self.eq(field, value)
      "#{field} = #{value}"
    end
  end
end