require "cgi"
require "http/server"

module Amatista
  module MVC
    class Base

      def initialize
        @routes = {} of String => String
      end

      def add_route(method, path, path_alias)
        @routes[path_alias] = path
      end

      def start(port)
        resource = ""
        server = HTTP::Server.new port, do |request|
          p request
          resource = if @routes.has_key?(request.path)
                       @routes[request.path] 
                     end

          if resource
            location = resource.try(&.split("/"))
            location.try(&.delete(""))
            if location
              controller = "#{location[0].capitalize}Controller"
              resource = location[1]
              execute_code("#{controller}.new.#{resource}")
            end
          end

          process(request)
        end
        p "Server running in #{port}"
        server.listen
      end

      def process(request)
        HTTP::Response.ok "text/plain", "Hola Mundo"
      end

      macro execute_code(code)
        {{code.id}}
      end
    end
  end
end

PORT = 1234
$amatista = Amatista::MVC::Base.new
