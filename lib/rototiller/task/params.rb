require 'rototiller/task/hash_handling'

module Rototiller
  module Task

    # The base class for creating rototiller task params (commands, envs, etc)
    # @since v0.1.0
    # @api public
    # @example ChildParam < RototillerParam
    # @attr [String] name The name of the param
    # @attr [String] message The param message (for debugging/informing/logging)
    class RototillerParam
      include HashHandling

      # @api public
      attr_accessor :name
      # @api public
      attr_accessor :message
      # @api public
      attr_accessor :parent_name
      # @api public
      attr_accessor :parent_message

      # we must always have a message that can be aggregated via the parent params
      # @api public
      # @example puts param.message
      # @return [String] <empty string>
      def message
        return ''
      end

      # @api public
      # @example param.parent_name = other_param.name
      # @return [void]
      def parent_name=(name)
        name.each_char do |char|
          message = "You have defined an environment variable with an illegal character: #{char}"
          raise ArgumentError.new(message) unless char =~ /[a-zA-Z]|\d|_/
        end
        @parent_name = name
      end

      # @api public
      # @example param.parent_message = other_param.message
      # @return [void]
      def parent_message=(message)
        @parent_message = message
      end
    end

  end
end
