require "rototiller/task/hash_handling"

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
        ""
      end

      # @api public
      # @example param.parent_name = other_param.name
      # @return [void]
      def parent_name=(name)
        name.each_char do |char|
          message = "You have defined an environment variable with an illegal character: #{char}"
          raise ArgumentError, message unless char =~ /[a-zA-Z]|\d|_/
        end
        @parent_name = name
      end

      # @api public
      # @example param.parent_message = other_param.message
      # @return [void]
      attr_writer :parent_message

      private

      ARG_ERROR_SUBSTR = "takes an Array of Hashes. Received Array of:".freeze
      # @api private
      def validate_hash_param_arg(arg)
        calling_method_name = caller_locations(1, 1)[0].label
        error_string = "#{calling_method_name} #{ARG_ERROR_SUBSTR} '#{arg.class}'"
        raise ArgumentError, error_string unless arg.is_a?(Hash)
      end
    end
  end
end
