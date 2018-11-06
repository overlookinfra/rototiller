require "rototiller/task/collections/env_collection"
require "rototiller/task/collections/command_collection"
require "rototiller/task/hash_handling"
require "rototiller/utilities/color_text"
require "rake/tasklib"

module Rototiller
  module Task
    # The main task type to implement base rototiller features in a Rake task
    # @since v0.1.0
    # @attr_reader [String] name The name of the task for calling via Rake
    # @attr [Boolean] fail_on_error Whether or not to fail Rake when an error
    #   occurs (typically when examples fail). Defaults to `true`.
    class RototillerTask < ::Rake::TaskLib
      include HashHandling
      include Rototiller::ColorText
      attr_reader :name
      # FIXME: make fail_on_error per-command
      attr_accessor :fail_on_error

      # create a task object with rototiller helper methods for building commands and creating
      #   debug/log messaging
      # see the rake-task documentation on things other than {.add_command} and {.add_env}
      # @param *args [Array<String>] same args as a rake task: a name, other dependent tasks
      # @yield block describing the RototillerTask including calls to our methods
      # @return [RakeTask] the rake task with added rototiller goodnestus
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
      # sort of private. it's needed by Rake. it should work fine, just not the *good* way to
      #   create a RototillerTask
      # @api private
      def self.define_task(*args, &task_block)
        new(*args, &task_block)
      end

      # adds environment variables to be tracked
      # @param [Hash] args hashes of information about the environment variable
      # @option args [String] :name The environment variable
      # @option args [String] :default The default value for the environment variable
      # @option args [String] :message A message describing the use of this variable
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the
      #   environment variable, available methods match hash keys
      # @api public
      # @example task.add_env({:name => "SOMENV"})
      def add_env(*args, &block)
        raise ArgumentError, "#{__method__} takes a block or a hash" if !args.empty? && block_given?
        # this is kinda annoying we have to do this for all params? (not DRY)
        #   have to do it this way so EnvVar doesn't become a collection
        #   but if this gets moved to a mixin, it might be more tolerable
        if block_given?
          @env_vars.push(EnvVar.new(&block))
        else
          # TODO: test this with array and non-array single hash
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            validate_hash_param_arg(arg)
            @env_vars.push(EnvVar.new(arg))
          end
        end
      end

      # adds sensitive environment variables to be tracked
      # @param [Hash] args hashes of information about the environment variable
      # @option args [String] :name The environment variable
      # @option args [String] :message A message describing the use of this variable
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the
      #   environment variable, available methods match hash keys
      # @api public
      # @example task.add_env({:name => "SOMENV"})
      def add_env_sensitive(*args, &block)
        raise ArgumentError, "#{__method__} takes a block or a hash" if !args.empty? && block_given?
        # this is kinda annoying we have to do this for all params? (not DRY)
        #   have to do it this way so EnvVar doesn't become a collection
        #   but if this gets moved to a mixin, it might be more tolerable
        if block_given?
          @env_vars.push(EnvVarSensitive.new(&block))
        else
          # TODO: test this with array and non-array single hash
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            validate_hash_param_arg(arg)
            @env_vars.push(EnvVarSensitive.new(arg))
          end
        end
      end

      # adds command to be executed by task
      # @param [Hash] args hash of information about the command to be executed
      # @option arg [String] :name The command to be executed
      # @option arg [String] :override_env An environment variable used to override the command to
      #   be executed by the task
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about command,
      #   available methods match hash keys
      # @api public
      # @example task.add_command({:name => "echo i echo stuff"})
      def add_command(*args, &block)
        raise ArgumentError, "#{__method__} takes a block or a hash" if !args.empty? && block_given?
        if block_given?
          @commands.push(Command.new(&block))
        else
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            validate_hash_param_arg(arg)
            @commands.push(Command.new(arg))
          end
        end
        # because add_command is at the top of the hierarchy chain,
        #   it has to return its produced object otherwise we yield on the blocks inside and
        #   don't have add_env that can handle an Array of hashes.
        @commands[-1] # FIXME: we should probably delegate param_collection#last
      end

      private

      # @api private
      def stop_task?
        return unless @env_vars.stop? || @commands.stop?
        $stderr.puts @commands.messages
        exit_code = 1
        exit exit_code
      end

      # @api private
      def run_task
        puts @env_vars.messages
        stop_task?
        run_commands
        @commands.map(&:result)
      end

      # @api private
      def run_commands
        @commands.each do |command|
          # print command and messages at top
          puts green_text("running: ") + command.safe_print
          puts command.message

          run_command(command)
          command_failed = command.result.exit_code > 0
          print_failed_and_exit(command) if command_failed
        end
      end

      # @api private
      def print_failed_and_exit(command)
        # print command and messages at bottom, if failed
        puts command
        $stderr.puts "  '#{command}' failed with exit code: #{command.result.exit_code}" if @verbose
        $stderr.puts command.message
        exit command.result.exit_code if fail_on_error
      end

      # @api private
      # rubocop:disable Style/RedundantBegin
      #   is this cop broken?
      # rubocop:disable Lint/HandleExceptions
      #   FIXME: we crush command exceptions here, on purpose so we can handle them elsewhere
      def run_command(command)
        begin
          command.run
        rescue Errno::ENOENT
        end
      end

      # register the new block w/ run_task call in a rake task
      #   any block passed is run prior to our command
      # TODO: probably need pre/post-command block functionality
      # @api private
      def define(args, &task_block)
        # Default task description
        # can be overridden with standard 'desc' DSL method
        unless ::Rake.application.last_description
          desc "RototillerTask: A Task with optional environment-variable and command-flag tracking"
        end

        task(@name, *args) do |_, task_args|
          RakeFileUtils.__send__(:verbose, @verbose) do
            yield(*[self, task_args].slice(0, task_block.arity)) if task_block
            run_task
          end
        end
      end

      #   for unit testing, we need a shortcut around rake's CLI --verbose
      # @api private
      def make_verbose(verbosity = true)
        @verbose = verbosity
      end
    end
  end
end
