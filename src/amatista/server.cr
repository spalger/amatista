require "cgi"
require "http/server"

module Server
  class Base
    getter params

    def initialize
      @params   = {} of String => Array(String)
      @actions  = [] of Response
      @location = ""
    end

    def run(port)
      server = HTTP::Server.new port, do |request|
        begin
          p request

          action = if request.path.to_s.match(/.js|.css/)
                     file = File.join(Dir.working_directory, request.path.to_s)
                     Response.new("GET", 
                                  request.path.to_s, 
                                  ->(x : Hash(String, Array(String))){ File.read(file) }) if File.exists?(file)
                   else
                     @actions.find {|response| response.match_path?(request.path.to_s) }
                   end

          return HTTP::Response.not_found unless action

          action.request_path = request.path.to_s
          action.add_params(CGI.parse(request.body.to_s))
          @params = action.get_params

          case action.method
          when "GET"
            HTTP::Response.ok "text/html", action.block.call(@params)
          when "POST", "PUT", "DELETE", "PATCH"
            HTTP::Response.new 307, action.block.call(@params), HTTP::Headers{"Location": @location}
          else
            raise "Path not Found"
          end
        rescue e
          HTTP::Response.error "text/plain", "Error: #{e}"
        end
      end
      server.listen
    end

    {% for method in %w(get post put delete patch) %}
      def {{method.id}}(route, &block : Hash(String, Array(String)) -> String)
        @actions << Response.new("{{method.id}}".upcase, route.to_s, block)
        yield(@params)
      end
    {% end %}

    def redirect_to(route)
      @location = route
    end
  end

  class Response
    property path
    property method
    property block
    property request_path

    def initialize(@method, @path, @block)
      @params = {} of String => Array(String)
      @request_path = ""
    end

    def get_params
      extract_params_from_path
      @params
    end

    def match_path?(path)
      return path == "/" if @path == "/"

      route_to_match = Regex.new(@path.to_s.gsub(/(:\w*)/, ".*"))
      path.match(route_to_match)
    end

    def add_params(params)
      params.each do |key, value|
        @params[key] = value
      end
    end

    private def extract_params_from_path
      params = @path.to_s.scan(/(:\w*)/).map(&.[](0))
      pairs  = @path.split("/").zip(@request_path.split("/"))
      pairs.select{|pair| params.includes?(pair[0])}.each do |p|
        @params[p[0].gsub(/:/, "")] = [p[1]]
      end
    end
  end
end