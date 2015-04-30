require "./amatista/mvc/**"

module Amatista
  module MVC
    class Main
      def self.run(port)
        $amatista.start(PORT)
      end
    end
  end
end
