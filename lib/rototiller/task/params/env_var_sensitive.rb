require "rototiller/task/params/env_var"

module Rototiller
  module Task
    # The main EnvVarSensitive type to implement sensitive envrironment variable handling
    #   this gets most functionality from EnvVar
    #   but we ensure the value is not printed in our logging.
    #   we also remove the default-value functionality so we don't promote saving these in repos
    # @since v1.1.0
    # @api public
    # @attr_reader stop [Boolean] Whether the state of the EnvVar requires the task to stop
    # @attr_reader value [Boolean] The value of the ENV based on specified default and
    #   environment state
    class EnvVarSensitive < EnvVar
      # remove parent's getters and setters
      undef_method :default=
      undef_method :default

      private

      # @api private
      def reset
        @stop = !env_value_provided_by_user?

        @value = ENV[@name]
        set_user_env unless env_value_provided_by_user?
      end

      # @api private
      def nodefault_exist_message(indent)
        INDENT_ARRAY[indent] + yellow_text("[I] ") +
          "'#{@name}': using system: '[REDACTED]'; '#{@message}'\n"
      end
    end
  end
end
