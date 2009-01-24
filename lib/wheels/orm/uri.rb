require "uri"
require "cgi"

module Wheels
  module Orm
    class Uri

      include Test::Unit::Assertions

      def initialize(uri)
        begin
          assert_kind_of(String, uri, "URI must be a String")
          assert_not_blank(uri, "URI must not be blank")
        rescue Test::Unit::AssertionFailedError => e
          raise ArgumentError.new(e.message)
        end

        @s = uri.dup

        if @s =~ /^jdbc:/
          uri = uri.sub(/^jdbc:/, "jdbc+")
        end

        uri = ::URI::parse(uri)

        @host = uri.path.to_s.size > 0 ? uri.host : "localhost"
        @name = uri.path.to_s.size > 0 ? uri.path : uri.host
        @user = uri.user
        @password = uri.password
        @options = uri.query ? CGI::parse(uri.query) : {}

        @options.each_pair do |key, value|
          @options[key] = value.first if key[-2..-1] != "[]" && value.kind_of?(Array) && value.size == 1
        end

        @driver = uri.scheme.split(/[\:\+]/).compact.inject(Wheels::Orm::Repositories) do |c, name|
          c.const_get(name.capitalize)
        end
      end

      def driver
        @driver
      end

      def name
        @name
      end

      def user
        @user
      end

      def password
        @password
      end

      def options
        @options
      end

      def to_s
        @s
      end
    end
  end
end