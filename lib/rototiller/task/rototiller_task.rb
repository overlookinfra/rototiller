require 'rototiller/task/collections/env_collection'
require 'rototiller/task/collections/command_collection'
require 'rake/tasklib'

module Rototiller
  module Task

    # The main task type to implement base rototiller features in a Rake task
    # @since v0.1.0
    # @attr_reader [String] name The name of the task for calling via Rake
    # @attr [Boolean] fail_on_error Whether or not to fail Rake when an error
    #   occurs (typically when examples fail). Defaults to `true`.
    class RototillerTask < ::Rake::TaskLib
      attr_reader :name
      # FIXME: make fail_on_error per-command
      attr_accessor :fail_on_error

      # create a task object with rototiller helper methods for building commands and creating debug/log messaging
      # see the rake-task documentation on things other than {.add_command} and {.add_env}
      def initialize(*args, &task_block)
        @name          = args.shift
        @fail_on_error = true
        @commands      = CommandCollection.new

        # rake's in-task implied method is true when using --verbose
        @verbose       = verbose == true
        @env_vars      = EnvCollection.new

        define(args, &task_block)
      end

      # define_task is included to allow task to work like Rake::Task
      # using .define_task or .new as appropriate
      def self.define_task(*args, &task_block)
        self.new(*args, &task_block)
      end

      # adds environment variables to be tracked
      # @param [Hash] args hashes of information about the environment variable
      # @option args [String] :name The environment variable
      # @option args [String] :default The default value for the environment variable
      # @option args [String] :message A message describing the use of this variable
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the environment variable, available methods match hash keys
      def add_env(*args, &block)
        raise ArgumentError.new("#{__method__} takes a block or a hash") if !args.empty? && block_given?
        # this is kinda annoying we have to do this for all params? (not DRY)
        #   have to do it this way so EnvVar doesn't become a collection
        #   but if this gets moved to a mixin, it might be more tolerable
        if block_given?
          @env_vars.push(EnvVar.new(&block))
        else
          #TODO: test this with array and non-array single hash
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            error_string = "#{__method__} takes an Array of Hashes. Received Array of: '#{arg.class}'"
            raise ArgumentError.new(error_string) unless arg.is_a?(Hash)
            @env_vars.push(EnvVar.new(arg))
          end
        end
      end

      # adds command to be executed by task
      # @param [Hash] args hash of information about the command to be executed
      # @option arg [String] :name The command to be executed
      # @option arg [String] :override_env An environment variable used to override the command to be executed by the task
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about command, available methods match hash keys
      def add_command(*args, &block)
        raise ArgumentError.new("#{__method__} takes a block or a hash") if !args.empty? && block_given?
        if block_given?
          new_command = Command.new(&block)
          @commands.push(new_command)
        else
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            error_string = "#{__method__} takes an Array of Hashes. Received Array of: '#{arg.class}'"
            raise ArgumentError.new(error_string) unless arg.is_a?(Hash)
            new_command = Command.new(arg)
            @commands.push(new_command)
          end
        end
        # because add_command is at the top of the hierarchy chain, it has to return its produced object
        #   otherwise we yield on the blocks inside and don't have add_env that can handle an Array of hashes.
        return new_command
      end


      private

      # @private
      def print_messages
        puts @commands.messages
        puts @env_vars.messages
      end

      # @private
      def stop_task?
        exit_code = 1
        exit exit_code if @env_vars.stop? || @commands.stop?
      end

      # @private
      def run_task
        print_messages
        stop_task?
        @commands.each do |command|
          puts command

          begin
            command.run
          rescue Errno::ENOENT => e
          end
          command_failed = command.result.exit_code > 0

          if command_failed
            $stderr.puts "'#{command}' failed" if @verbose
            $stderr.puts command.message
            $stderr.puts @env_vars.messages
            exit command.result.exit_code if fail_on_error
          end
        end
        # might be useful in output of t.add_command()?  but if not, Command has #result
        return @commands.map{ |command| command.result }
      end

      # @private
      # register the new block w/ run_task call in a rake task
      #   any block passed is run prior to our command
      # TODO: probably need pre/post-command block functionality
      def define(args, &task_block)
        # Default task description
        # can be overridden with standard 'desc' DSL method
        desc 'RototillerTask: A Task with optional environment-variable and command-flag tracking' unless ::Rake.application.last_description

        task(@name, *args) do |_, task_args|
          RakeFileUtils.__send__(:verbose, @verbose) do
            task_block.call(*[self, task_args].slice(0, task_block.arity)) if task_block
            run_task
          end
        end
      end

      # @private
      #   for unit testing, we need a shortcut around rake's CLI --verbose
      def set_verbose(verbosity=true)
        @verbose = verbosity
      end

    end

  end
end
