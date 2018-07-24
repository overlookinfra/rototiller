require "rototiller/task/params/argument"
require "rototiller/task/collections/switch_collection"

module Rototiller
  module Task
    # @api public
    # @example ArgumentCollection.new
    class ArgumentCollection < SwitchCollection
      # Ensure we only have arguments in this collection
      # @return [Type] allowed class for this collection (Argument)
      # @api public
      # @example assert(Klass == ArgumentCollection.allowed_class)
      def allowed_class
        Argument
      end
    end
  end
end
