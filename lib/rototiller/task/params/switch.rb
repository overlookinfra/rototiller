require "rototiller/task/collections/env_collection"

module Rototiller
  module Task
    # The Switch class to implement rototiller command switch handling
    #   via a RototillerTask's #add_command and Command's #add_switch
    #   contains information about a Switch's state, as influenced by environment variables,
    #     for instance
    # @since v1.0.0
    # @attr [String] name The name of the switch to add to a command string
    class Switch < RototillerParamWithEnv
      # @return [String] the command to be used, could be considered a default
      # FIXME: this really needs a test, or to not have accessors
      attr_accessor :name

      # Creates a new instance of Switch
      # @param [Hash,Array<Hash>] args hashes of information about the switch
      # for block { |b| ... }
      # @yield Switch object with attributes matching method calls supported by Switch
      # @return Switch object
      def initialize(args = {})
        # the env_vars that override the name
        @env_vars = EnvCollection.new
        block_given? ? (yield self) : send_hash_keys_as_methods_to_self(args)
        # do this after we have done the rest of init, so @name can be re-set
        set_param_name_from_our_env_vars
      end

      # Does this param require the task to stop
      # Determined by the interactions between @name and @env_vars
      # @return [true|nil] if this param requires a stop
      def stop
        true unless @name
      end

      # @return [String] formatted messages from all of Switch's pieces
      #   itself, env_vars
      def message(indent = 0)
        [@env_vars.messages(indent)].join ""
      end

      # The string representation of this Switch; the value sent by author, or
      #   overridden by any env_vars
      # @return [String] the Switch's value
      def to_str
        @name.to_s
      end
      alias to_s to_str
    end
  end
end
