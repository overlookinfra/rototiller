require "beaker/hosts"
require "rakefile_tools"
require "test_utilities"

test_name "C98981: params can set and display messages" do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  test_filename = File.basename(__FILE__, ".*")
  rakefile_contents = ""
  # ensure these are unique. we're not using task.length here
  tasks = []

  step "command message" do
    task_name = "bare_command_with_message"
    rakefile_contents << <<-EOS
      rototiller_task :#{task_name} do |t|
          t.add_command({:name => 'echo i can has message', :message => '#{task_name}'})
      end
    EOS
    tasks << task_name
  end

  step "create Rakefile, execute tasks" do
    rakefile_path = create_rakefile_on(sut, rakefile_contents)

    tasks.each do |task|
      execute_task_on(sut, task, rakefile_path, {:verbose => true}) do |result|
        assert_match(/#{task}/, result.stdout, "The correct switch was not observed (#{task})")
      end
    end
  end
end
