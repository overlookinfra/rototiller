require "beaker/hosts"
require "rakefile_tools"
require "test_utilities"

test_name "C97797: ensure environment variable operation in RototillerTasks" do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  step "For environment variables that will succeed" do
    env_vars = [
      { name: "NO_DEFAULT_EXISTS",        message: "no default previously exists",
        exists: true },
      { name: "DEFAULT_EXISTS",           message: "default previously exists",
        exists: true,   default: "present default value" },
      { name: "DEFAULT_NO_EXISTS",        message: "default does notpreviously exist",
        exists: false,  default: "DEFAULT-NO_EXISTS: notpresent default value" },
      { name: "DEFAULT_EXISTS_BLOCK",     message: "default previously exists",
        exists: true,   default: "present default value",  block_syntax: true },
      { name: "DEFAULT_NO_EXISTS_BLOCK",  message: "default does notpreviously exist",
        exists: false,  default: "DEFAULT-NO_EXISTS-BLOCK: notpresent default value", block_syntax: true },
      { name: "NO_DEFAULT_EXISTS_BLOCK",  message: "no default previously exists",
        exists: true,   block_syntax: true }
    ]
    env_vars = env_vars.each { |e| e[:type] = :env }

    @task_name = "env_var_testing_task"
    rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
    #{create_rakefile_task_segment(env_vars)}
end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)

    execute_task_on(sut, @task_name, rakefile_path) do |result|
      env_vars.each do |env|
        # validate notification to user of ENV value
        rototiller_message_match = env[:exists] ?
          /\[I\].*'#{env[:name]}'.*present value.*#{env[:message]}/ :
          /\[I\].*'#{env[:name]}'.*#{env[:message]}/
          assert_match(rototiller_message_match, result.stdout,
                       "The expected messaging was not observed for: '#{env[:name]}")

        # Use test command output to validate value of ENV used by task
        task_out_match = env[:exists] ? /#{env[:name]}: env present value/m :
          /#{env[:name]}/m
        assert_match(task_out_match, result.stdout,
                     "The printed env was different than expected for: '#{env[:name]}'")
      end
    end
  end

  step "For environment variables that will fail" do
    env_vars_fail = [
      { name: "NO_DEFAULT_NO_EXISTS", message: "no default, does not previously exist",
        exists: false },
      { name: "NO_DEFAULT_NO_EXISTS_BLOCK", message: "no default, does not previously exist",
        exists: false }
    ]
    env_vars_fail = env_vars_fail.each { |e| e[:type] = :env }

    rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
    #{create_rakefile_task_segment(env_vars_fail)}
end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)

    step "Execute task defined in rake task" do
      on(sut, "rake #{@task_name} --rakefile #{rakefile_path}", accept_all_exit_codes: true) do |result|
        # exit code & no error in output
        assert(result.exit_code == 1, "The expected exit code 1 was not observed")

        env_vars_fail.each do |env|
          # validate notification to user of ENV value
          rototiller_message_match = /\[E\].*'#{env[:name]}'.*#{env[:message]}/
            assert_match(rototiller_message_match, result.stdout,
                         "The expected messaging was not observed for: '#{env[:name]}")
        end
      end
    end
  end
end
