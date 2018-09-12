require "beaker/hosts"
require "rakefile_tools"
require "test_utilities"

test_name "An env should error when supplied an invalid character for an ENV" do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  invalid_characters = ["-", "=", "$"].each do |character|
    block_body = {
      add_command: {
        add_env: { name: "bad_#{character}", message: "I am bad", default: "SO BAD!" }
      }
    }

    task_name = "you_know_im_bad"

    rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{task_name} do |x|
  #{RototillerBodyBuilder.new(block_body)}
end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)

    step "Attempt to run task" do
      execute_task_on(sut, task_name, rakefile_path, accept_all_exit_codes: true) do |result|
        rototiller_output_regex = /You have defined an environment variable with an illegal character: /
        assert_msg = "The expected output was not observed"
        assert_match(rototiller_output_regex, result.stderr, assert_msg)
        assert(result.exit_code == 1, "The expected error message was not observed")
      end
    end
  end
end
