require "../spec_helper"

describe Quick::Response do
  context ".find_route" do
    it "find path /tasks/new from a group of routes" do
      routes = [Quick::Route.new("GET", "/tasks/new", ->(x : Hash(String, Array(String))){})]
      50.times do |n|
        routes << Quick::Route.new("GET", "/tasks/#{n}", ->(x : Hash(String, Array(String))){})
      end

      route = Quick::Response.find_route(routes, "GET", "/tasks/new")

      route.path.should eq("/tasks/new") if route
    end

    it "does not find path" do
      routes = [Quick::Route.new("GET", "/tasks/new", ->(x : Hash(String, Array(String))){})]
      50.times do |n|
        routes << Quick::Route.new("GET", "/tasks/#{n}", ->(x : Hash(String, Array(String))){})
      end

      route = Quick::Response.find_route(routes, "GET", "/tasks/edit")

      route.should be_nil
    end

    it "find the GET method route" do
      routes = [Quick::Route.new("GET", "/tasks", ->(x : Hash(String, Array(String))){}), 
                Quick::Route.new("PUT", "/tasks", ->(x : Hash(String, Array(String))){}),
                Quick::Route.new("POST", "/tasks", ->(x : Hash(String, Array(String))){})]


      route = Quick::Response.find_route(routes, "GET", "/tasks")

      if route
        route.method.should eq("GET")
        route.path.should eq("/tasks")
      end
    end

    it "find the POST method route" do
      routes = [Quick::Route.new("GET", "/tasks", ->(x : Hash(String, Array(String))){}), 
                Quick::Route.new("POST", "/tasks", ->(x : Hash(String, Array(String))){}),
                Quick::Route.new("DELETE", "/tasks", ->(x : Hash(String, Array(String))){})]

      route = Quick::Response.find_route(routes, "POST", "/tasks")

      if route
        route.method.should eq("POST")
        route.path.should eq("/tasks")
      end
    end
  end

  context "#process_static" do
    it "process a js file" do
      headers = HTTP::Headers.new
      headers["Host"] = "host.domain.com"
      headers["Body"] = nil

      request = HTTP::Request.new "GET", "/", headers

      response = Quick::Response.new(request)

      filename = "jquery.js"
      File.open("jquery.js", "w") { |f| f.puts "jquery" }

      route   = response.process_static("jquery.js")
      content = route.block.call({"" => [""]}) if route

      content.body.should eq("jquery\n") if content

      File.delete(filename)
    end

    it "does not process file" do
      headers = HTTP::Headers.new
      headers["Host"] = "host.domain.com"
      headers["Body"] = nil

      request  = HTTP::Request.new "GET", "/", headers
      response = Quick::Response.new(request)
      route    = response.process_static("jquery.js")

      route.should be_nil
    end
  end

  context "#process_params" do
      headers = HTTP::Headers.new
      headers["Host"] = "host.domain.com"
      headers["Body"] = nil

      request  = HTTP::Request.new "GET", "/tasks/edit/2/soon/34", headers
      response = Quick::Response.new(request)
      route    = Quick::Route.new("GET", "/tasks/edit/:id/soon/:other_task", ->(x : Hash(String, Array(String))){})
      route.request_path = "/tasks/edit/2/soon/34"

      response.process_params(route).should eq({"" => [""], "id" => ["2"], "other_task" => ["34"]})
  end
end
