require "beaker/hosts"
require "rakefile_tools"
require "test_utilities"

test_name "can add multiple commands in a RototillerTask" do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  test_name     = File.basename(__FILE__, ".*")
  @task_name    = test_name
  step "Add two commands with hashes" do
    rakefile_contents = <<-EOS
    #{rototiller_rakefile_header}
rototiller_task :#{@task_name} do |t|
    t.add_command({:name => 'echo', :add_argument => {:name => 'command1'}})
    t.add_command({:name => 'echo', :add_argument => {:name => 'command2'}})
end
    EOS

    rakefile_path = create_rakefile_on(sut, rakefile_contents)
    execute_task_on(sut, @task_name, rakefile_path) do |result|
      assert_match(/^command1/, result.stdout, "The correct command was not observed")
      assert_match(/^command2/, result.stdout, "The correct command was not observed")
    end
  end

  step "Add two commands with blocks" do
    rakefile_contents = <<-EOS
    #{rototiller_rakefile_header}
rototiller_task :#{@task_name} do |t|
    t.add_command { |c| c.name = 'echo'; c.add_argument({:name => 'command1'})}
    t.add_command { |c| c.name = 'echo'; c.add_argument({:name => 'command2'})}
end
    EOS

    rakefile_path = create_rakefile_on(sut, rakefile_contents)
    execute_task_on(sut, @task_name, rakefile_path) do |result|
      assert_match(/^command1/, result.stdout, "The correct command was not observed")
      assert_match(/^command2/, result.stdout, "The correct command was not observed")
    end
  end

  step "Add two commands, one block one hash" do
    rakefile_contents = <<-EOS
    #{rototiller_rakefile_header}
rototiller_task :#{@task_name} do |t|
    t.add_command({:name => 'echo', :add_argument => {:name => 'command1'}})
    t.add_command { |c| c.name = 'echo'; c.add_argument({:name => 'command2'})}
end
    EOS

    rakefile_path = create_rakefile_on(sut, rakefile_contents)
    execute_task_on(sut, @task_name, rakefile_path) do |result|
      assert_match(/^command1/, result.stdout, "The correct command was not observed")
      assert_match(/^command2/, result.stdout, "The correct command was not observed")
    end
  end
end
