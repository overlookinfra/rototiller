require "rototiller/task/collections/param_collection"
require "rototiller/task/params/option"

module Rototiller
  module Task
    # The OptionCollection class to collect more than one option for a Command
    #   delegates to Array via inheritance from ParamCollection
    # @api public
    # @example OptionCollection.new
    # @since v1.0.0
    class OptionCollection < ParamCollection
      # set allowed classes to be inserted into this Collection/Array
      # @api public
      # @example assert(Klass == OptionCollection.allowed_class)
      # @return [Option] the collection's allowed class
      def allowed_class
        Option
      end
    end
  end
end
