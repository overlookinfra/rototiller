require "rototiller/task/rototiller_task"

module Rake
  module DSL
    # The main task type to implement base rototiller features in a Rake task
    # @since v0.1.0
    # create a task object with rototiller helper methods for building commands and creating debug/log messaging
    # see the rake-task documentation on things other than {.add_command} and {.add_env}
    # @api public
    # @example rototiler_task :taskname { puts "hi" }
    # @return [RototillerTask]
    def rototiller_task(*args, &block)
      Rototiller::Task::RototillerTask.define_task(*args, &block)
    end
  end
end
