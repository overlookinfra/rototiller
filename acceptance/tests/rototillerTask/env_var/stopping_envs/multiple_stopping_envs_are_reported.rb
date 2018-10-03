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
    # sigh: work around beaker (BKR-1526) clear_env_var bug if no env_vars have been set yet
    sut.add_env_var('NADA','NONE')
    [task_env, command_arg_env, command_env, switch_env, option_env, option_arg_env].each do |env|
      sut.clear_env_var(env[:name])
    end
  end

  @task_name = "multiple_stoppping_envs"

  rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
  t.add_env(#{task_env})

  t.add_command do |c|
    c.name = 'echo my_sweet_command ${HOME}'
    c.add_env(#{command_env})
    c.add_argument do |a|
      a.name = 'argument'
      a.add_env(#{command_arg_env})
    end
    c.add_switch do |s|
      s.name = '--switch'
      s.add_env(#{switch_env})
    end
    c.add_option do |o|
      o.name = '--option'
      o.add_env(#{option_env})
      c.add_argument do |a|
        a.name = 'optionargument'
        a.add_env(#{option_arg_env})
      end
    end
  end
end
  EOS
  rakefile_path = create_rakefile_on(sut, rakefile_contents)

  # add env to command
  step "Run rake task defined in block syntax, ENV not set" do
    execute_task_on(sut, @task_name, rakefile_path, accept_all_exit_codes: true) do |result|
      assert_no_match(/RUNNING/, result.stdout, "The command ran when it wasn't expected to")

      rototiller_output_regex = /\[E\] required: .*#{task_env[:name]}.*#{task_env[:message]}/
      assert_msg = 'The expected output was not observed'
      assert_match(rototiller_output_regex, result.stdout, assert_msg)
      assert(result.exit_code == 1, "The expected error message was not observed")
    end
  end
end
