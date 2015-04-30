module Amatista
  module MVC
    class Route
      {% for method in %w(get post put delete patch) %}
        def self.{{method.id}}(path, path_alias = nil)
          $amatista.add_route({{method.upcase}}, path, path_alias || path)
        end
      {% end %}
    end
  end
end
