require "beaker/hosts"
require "rakefile_tools"
require "test_utilities"

test_name " can override key/value option argument in a RototillerTask" do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  option_name = "--foo"
  option_argument = "baz"

  test_filename = File.basename(__FILE__, ".*")
  override_env = test_filename.upcase + random_string
  env_value = "I_CAME_FROM_THE_ENVIRONMENT"

  @block_syntax = "block_syntax"
  block_body = {
    add_command: {
      name: "echo", add_option: {
        name: option_name, add_argument: {
          name: option_argument, add_env: {
            name: override_env
          }
        }
      }
    }
  }

  # create a second task defined with hash syntax
  @hash_syntax = "hash_syntax"
  hash_body = block_body
  hash_body[:add_command][:add_option][:keep_as_hash] = true

  rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{@block_syntax} do |x|
  #{RototillerBodyBuilder.new(block_body)}
end

Rototiller::Task::RototillerTask.define_task :#{@hash_syntax} do |x|
  #{RototillerBodyBuilder.new(hash_body)}
end
  EOS
  rakefile_path = create_rakefile_on(sut, rakefile_contents)

  step "Run rake task defined in block syntax, ENV not set" do
    execute_task_on(sut, @block_syntax, rakefile_path) do |result|
      command_regex = /#{option_name} #{option_argument}/
      assert_match(command_regex, result.stdout, "The option argument #{option_name} was not observed on the command line in block syntax")
    end
  end

  step "Run rake task with add_option defined as a hash, ENV not set" do
    execute_task_on(sut, @hash_syntax, rakefile_path) do |result|
      command_regex = /#{option_name} #{option_argument}/
      assert_match(command_regex, result.stdout, "The option #{option_name} was not observed on the command line in hash syntax")
    end
  end

  step "Set the env on the host" do
    sut.add_env_var(override_env, env_value)
  end

  step "Run rake task defined in block syntax, ENV set" do
    execute_task_on(sut, @block_syntax, rakefile_path) do |result|
      command_regex = /#{option_name} #{env_value}/
      assert_match(command_regex, result.stdout, "The option argument #{env_value} was not observed on the command line in block syntax")
    end
  end

  step "Run rake task with add_option defined as a hash, ENV set" do
    execute_task_on(sut, @hash_syntax, rakefile_path) do |result|
      command_regex = /#{option_name} #{env_value}/
      assert_match(command_regex, result.stdout, "The option argument #{env_value} was not observed on the command line in hash syntax")
    end
  end
end
