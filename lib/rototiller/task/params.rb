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

      # we must always have a message that can be aggregated via the parent params
      # @api public
      # @example puts param.message
      # @return [String] <empty string>
      def message
        ""
      end

    end

    # The base class for creating rototiller task params that are allowed envs (commands, etc)
    # @since v1.1.0
    # @api public
    # @example ChildParam < RototillerParam
    # @attr [String] name The name of the param
    # @attr [String] message The param message (for debugging/informing/logging)
    class RototillerParamWithEnv < RototillerParam
      def initialize(args = {})
        # the env_vars that override the name
        @env_vars = EnvCollection.new

        block_given? ? (yield self) : send_hash_keys_as_methods_to_self(args)
        # do this after we have done the rest of init, so @name can be re-set
        set_param_name_from_our_env_vars
      end

      # adds environment variables to be tracked, messaged.
      #   In the Param context this env_var overrides the param's "name"
      # @param [Hash] args hashes of information about the environment variable
      # @option args [String] :name The environment variable
      # @option args [String] :default The default value for the environment variable
      # @option args [String] :message A message describing the use of this variable
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the
      #   environment variable, available methods match hash keys
      def add_env(*args, &block)
        raise ArgumentError, "#{__method__} takes a block or a hash" if !args.empty? && block_given?
        # this is kinda annoying we have to do this for all params? (not DRY)
        #   have to do it this way so EnvVar doesn't become a collection
        #   but if this gets moved to a mixin, it might be more tolerable
        if block_given?
          # send in the name of this Param, so it can be used when no default is given to add_env
          @env_vars.push(EnvVar.new({ parent_name: @name }, &block))
        else
          # TODO: test this with array and non-array single hash
          add_hash_env(args)
        end
        #   do this every time a new env_var is created (thus here)
        set_param_name_from_our_env_vars
      end

      private

      # @api private
      # our name/value is the value of the last env_var set, if any
      def set_param_name_from_our_env_vars
        @name = @env_vars.last if @env_vars.last
      end

      # @api private
      def add_hash_env(args)
        args.each do |arg| # we can accept an array of hashes, each of which defines a param
          validate_hash_param_arg(arg)
          # send in the name of this Param, so it can be used when no default is given to add_env
          arg[:parent_name] = @name
          @env_vars.push(EnvVar.new(arg))
        end
      end
    end
  end
end
