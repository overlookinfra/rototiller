require "beaker/hosts"
extend Beaker::Hosts
require "rakefile_tools"
extend RakefileTools
require "test_utilities"
extend TestUtilities

test_name "C98542 - EnvVar values must be set in the environment during task execution" do
  step "Set environment variables on the SUT" do
    sut.add_env_var("ALREADY_SET_SHOULD_PERSIST", "original_value")
    sut.add_env_var("ALREADY_SET_SHOULD_UPDATE", "original_value")
    sut.clear_env_var("NOT_SET_SHOULD_DEFAULT")
  end

  task_name = "env_checker"
  rakefile_path = ""
  step "Create Rakefile on SUT" do
    rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{task_name} do |t|
    t.add_env({:name    => 'ALREADY_SET_SHOULD_PERSIST',
               :message => 'This is required to already be set ahead of running the task'})
    t.add_env({:name    => 'ALREADY_SET_SHOULD_UPDATE',
               :message => 'This is required to already be set ahead of running the task'})
    t.add_env({:name    => 'NOT_SET_SHOULD_DEFAULT',
              :default => 'defaulted_ok',
              :message => 'This is expected to not be set, it can just default'})

    ENV['ALREADY_SET_SHOULD_UPDATE'] = 'updated_value'

    t.add_command({:name => 'echo "ALREADY_SET_SHOULD_PERSIST is $ALREADY_SET_SHOULD_PERSIST \
                             ALREADY_SET_SHOULD_UPDATE is $ALREADY_SET_SHOULD_UPDATE \
                             NOT_SET_SHOULD_DEFAULT is $NOT_SET_SHOULD_DEFAULT"'})
end
EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)
  end

  step "Assert existing environment values before rototilling" do
    on(sut, "echo $ALREADY_SET_SHOULD_PERSIST") do |output|
      assert_equal("original_value", output.stdout.chomp,
                   "Prior value of environment value not as expected prior to running rototiller")
    end
    on(sut, "echo $ALREADY_SET_SHOULD_UPDATE") do |output|
      assert_equal("original_value", output.stdout.chomp,
                   "Prior value of environment value not as expected prior to running rototiller")
    end
    on(sut, "echo $NOT_SET_SHOULD_DEFAULT") do |output|
      assert_equal("", output.stdout.chomp,
                   "Prior value of environment value not as expected prior to running rototiller")
    end
  end

  step "Execute task and assert environment values" do
    execute_task_on(sut, task_name, rakefile_path, accept_all_exit_codes: true) do |output|
      # command was used that was supplied by the override_env
      assert_match(/ALREADY_SET_SHOULD_PERSIST is original_value/, output.stdout,
                   "Environment variable value was not set during task execution")
      assert_match(/ALREADY_SET_SHOULD_UPDATE is updated_value/, output.stdout,
                   "Environment variable did not have updated value during task execution")
      assert_match(/NOT_SET_SHOULD_DEFAULT is defaulted_ok/, output.stdout,
                   "Unset environment variable did not take default value during task execution")
    end
  end
end
