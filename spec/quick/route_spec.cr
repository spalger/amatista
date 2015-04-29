require "../spec_helper"

describe Quick::Route do
  context "#match_path?" do
    it "match the root path to true" do
      route = Quick::Route.new("GET", "/", ->(params : Hash(String, Array(String))) {})

      route.match_path?("/").should eq(true)
    end
  
    it "match /tasks/edit/:id with /tasks/edit/2" do
      route = Quick::Route.new("GET", "/tasks/edit/:id", ->(params : Hash(String, Array(String))) {})

      route.match_path?("/tasks/edit/2").should eq(true)
    end

    it "match /tasks/edit/:id with /tasks/edit/2/" do
      route = Quick::Route.new("GET", "/tasks/edit/:id", ->(params : Hash(String, Array(String))) {})

      route.match_path?("/tasks/edit/2/").should eq(true)
    end

    it "does not match /tasks/edit/:id with /tasks/edit/2" do
      route = Quick::Route.new("GET", "/tasks/edit/:id", ->(params : Hash(String, Array(String))) {})

      route.match_path?("/tasks/edit/2/show").should eq(false)
    end
  end

  context "#get_params" do
    it "extracts params from /tasks/edit/:id" do
      route = Quick::Route.new("GET", "/tasks/edit/:id", ->(params : Hash(String, Array(String))) {})

      route.request_path = "/tasks/edit/2"
      route.add_params({"description" => ["some description"]})

      route.get_params.should eq({"description" => ["some description"], "id" => ["2"]})
    end
  end
end
