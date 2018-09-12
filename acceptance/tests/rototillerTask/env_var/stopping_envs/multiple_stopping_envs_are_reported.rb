require "beaker/hosts"
require "rakefile_tools"
require "test_utilities"

test_name "Multiple ENVs should stop when attached at all possible levels" do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  # ENVs for every level
  # no default assumed at task level
  task_env          = { name: "TASK_STOP",        message: "I will stop the task" }

  # set default to false to indicate task should stop
  command_env       = { name: "COMMAND_STOP",     message: "I will stop the task" }
  command_arg_env   = { name: "COMMAND_ARG_STOP", message: "I will stop the task" }
  switch_env        = { name: "SWITCH_STOP",      message: "I will stop the task" }
  option_env        = { name: "OPTION_STOP",      message: "I will stop the task" }
  option_arg_env    = { name: "OPTION_ARG_STOP",  message: "I will stop the task" }

  step "make sure that all envs are not set before proceeding" do
    [task_env, command_arg_env, command_env, switch_env, option_env, option_arg_env].each do |env|
      sut.clear_env_var(env[:name])
    end
  end

  @block_syntax = "block_syntax"

  block_body = {
    add_env: task_env,
    add_command: {
      add_env: command_env,
      add_argument: command_arg_env,
      add_switch: { add_env: switch_env },
      add_option: { add_env: option_env,
                    add_argument: { add_env: option_arg_env } }
    }
  }

  rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{@block_syntax} do |x|
  #{RototillerBodyBuilder.new(block_body)}
end
  EOS
  rakefile_path = create_rakefile_on(sut, rakefile_contents)

  # add env to command
  step "Run rake task defined in block syntax, ENV not set" do
    execute_task_on(sut, @block_syntax, rakefile_path, accept_all_exit_codes: true) do |result|
      assert_no_match(/RUNNING/, result.stdout, "The command ran when it wasn't expected to")

      rototiller_output_regex = /\[E\] required: .*#{task_env[:name]}.*#{task_env[:message]}/
      assert_msg = 'The expected output was not observed'
      assert_match(rototiller_output_regex, result.stdout, assert_msg)
      assert(result.exit_code == 1, "The expected error message was not observed")
    end
  end
end
