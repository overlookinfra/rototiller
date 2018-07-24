require "rototiller/task/collections/param_collection"
require "rototiller/task/params/switch"

module Rototiller
  module Task
    # The SwitchCollection class to collect more than one switch for a Command
    #   delegates to Array via inheritance from ParamCollection
    # @api public
    # @example SwitchCollection.new
    # @since v1.0.0
    class SwitchCollection < ParamCollection
      # set allowed classes to be inserted into this Collection/Array
      # @api public
      # @example assert(Klass == SwitchCollection.allowed_class)
      # @return [Switch] the collection's allowed class
      def allowed_class
        Switch
      end
    end
  end
end
