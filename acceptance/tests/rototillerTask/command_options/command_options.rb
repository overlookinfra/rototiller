require "beaker/hosts"
require "rakefile_tools"
require "test_utilities"

test_name "C97820: can set key/value option in a RototillerTask" do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  option_name = "--foo"
  option_argument = "baz"

  @block_syntax = "block_syntax"
  block_body = {
    add_command: {
      name: "echo", add_option: {
        name: option_name, add_argument: {
          name: option_argument
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

  step "Run rake task defined in block syntax" do
    execute_task_on(sut, @block_syntax, rakefile_path) do |result|
      command_regex = /#{option_name} #{option_argument}/
      assert_match(command_regex, result.stdout, "The option #{option_name} was not observed on the command line in block syntax")
    end
  end

  step "Run rake task with add_option defined as a hash" do
    execute_task_on(sut, @hash_syntax, rakefile_path) do |result|
      command_regex = /#{option_name} #{option_argument}/
      assert_match(command_regex, result.stdout, "The option #{option_name} was not observed on the command line in hash syntax")
    end
  end
end
