require 'rototiller/task/hash_handling'

module Rototiller
  module Task

    # The base class for creating rototiller task params (commands, envs, etc)
    # @since v0.1.0
    # @attr [String] name The name of the param
    # @attr [String] message The param message (for debugging/informing/logging)
    class RototillerParam
      include HashHandling

      attr_accessor :name
      attr_accessor :message
      attr_accessor :parent_name
      attr_accessor :parent_message

      # we must always have a message that can be aggregated via the parent params
      # @return [String] <empty string>
      def message
        return ''
      end

      def parent_name=(name)
        name.each_char do |char|
          message = "You have defined an environment variable with an illegal character: #{char}"
          raise ArgumentError.new(message) unless char =~ /[a-zA-Z]|\d|_/
        end
        @parent_name = name
      end

      def parent_message=(message)
        @parent_message = message
      end
    end

  end
end
