# beaker host helper to find the single sut
module Beaker
  # beaker host helper to find the single sut
  module Hosts
    def sut
      find_only_one("agent")
    end
  end
end
