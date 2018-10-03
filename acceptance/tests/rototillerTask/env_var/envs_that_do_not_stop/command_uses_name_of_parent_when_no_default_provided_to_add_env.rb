require "beaker/hosts"
require "rakefile_tools"
require "test_utilities"

test_name "A command should use the commands name when default is not supplied through add_env" do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  # an env with default should not stop the task when attached to a command
  env_no_default = { name: "DONTSTOP", message: "Dont STOP BELIEVING" }
  sut.clear_env_var(env_no_default[:name])

  @block_syntax = "block_syntax"

  block_body = {
    add_command: {
      name: "echo I_am_the_commands_name",
      add_env: env_no_default
    }
  }

  test_env_validation = "Journey"
  test_env_value = "echo #{test_env_validation}"

  rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{@block_syntax} do |x|
  #{RototillerBodyBuilder.new(block_body)}
end
  EOS
  rakefile_path = create_rakefile_on(sut, rakefile_contents)

  teardown do
    sut.clear_env_var(env_no_default[:name])
  end

  # add env to command
  step "Run rake task defined in block syntax, ENV not set" do
    execute_task_on(sut, @block_syntax, rakefile_path) do |result|
      assert_match(/I_am_the_commands_name/, result.stdout, "The expected command was not observed")

      rototiller_output_regex = /\[I\] .*#{env_no_default[:name]}.*using default.*#{env_no_default[:default]}.*#{env_no_default[:message]}/
      assert_msg = 'The expected output was not observed'
      assert_match(rototiller_output_regex, result.stdout, assert_msg)
      assert(result.exit_code == 0, "The expected message was not observed")
    end
  end

  step "Use ENV to override command" do
    sut.add_env_var(env_no_default[:name], test_env_value)

    execute_task_on(sut, @block_syntax, rakefile_path) do |result|
      assert_match(/#{test_env_validation}/, result.stdout, "The command was not overridden by the value of the ENV")

      rototiller_output_regex = /\[I\] .*#{env_no_default[:name]}.*using system.*default.*#{env_no_default[:default]}.*#{env_no_default[:message]}/
      assert_msg = 'The expected output was not observed'
      assert_match(rototiller_output_regex, result.stdout, assert_msg)
      assert(result.exit_code == 0, "The expected message was not observed")
    end
  end
end
