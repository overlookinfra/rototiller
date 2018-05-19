require 'rototiller/task/collections/param_collection'
require 'rototiller/task/params/command'

module Rototiller
  module Task

    # @api public
    # @example CommandCollection.new
    class CommandCollection < ParamCollection
      # Ensure we only have arguments in this collection
      # @return [Type] allowed class for this collection (Command)
      # @api public
      # @example assert(Klass == CommandCollection.allowed_class)
      def allowed_class
        Command
      end
    end

  end
end
