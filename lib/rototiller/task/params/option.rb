require 'rototiller/task/collections/env_collection'
require 'rototiller/task/collections/argument_collection'

module Rototiller
  module Task

    # The Option class to implement rototiller command Option handling
    #   via a RototillerTask's #add_command and Command's #add_option
    #   contains information about a Switch's state, as influenced by environment variables, for instance
    # @since v1.0.0
    # @attr [String] name The name of the option to add to a command string
    class Option < Switch

      def initialize(args={}, &block)
        @arguments = ArgumentCollection.new
        super(args, &block)
      end

      # adds argument to append to option.
      #   In the Option context this Argument is added to an Option '--option argument'
      # @param [Hash] args hashes of information about the argument
      # @option args [String] :name The value to be used as the argument
      # @option args [String] :message A message describing the use of argument
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the argument, available methods match hash keys
      def add_argument(*args, &block)
        raise ArgumentError.new("#{__method__} takes a block or a hash") if !args.empty? && block_given?
        if block_given?
          @arguments.push(Argument.new(&block))
        else
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            error_string = "#{__method__} takes an Array of Hashes. Received Array of: '#{arg.class}'"
            raise ArgumentError.new(error_string) unless arg.is_a?(Hash)
            @arguments.push(Argument.new(arg))
          end
        end
      end

      # @return [String] current value of this Option and its argument, based upon itself, defaults and environment variables
      #   used to form the complete, runable command string
      def to_str
        [@name.to_s, @arguments.to_s].compact.join(' ')
      end

      # @return [String] formatted messages from all of Switch's pieces
      #   itself, env_vars
      # TODO make private method? so that it will throw an error if yielded to?
      def message
        return_message = [@message, @env_vars.messages, @arguments.messages].join ''
        return_message += "\n" unless return_message == ''
        return return_message
      end

      # Does this param require the task to stop
      # Determined by the interactions between @name, @env_vars, @arguments
      # @return [true|nil] if this param requires a stop
      def stop
        return true if @arguments.stop?
        return true unless @name
      end

    end
  end
end
