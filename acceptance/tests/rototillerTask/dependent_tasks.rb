require "beaker/hosts"
require "rakefile_tools"
require "test_utilities"

test_name "C97794: ensure RototillerTasks can be parent/child tasks" do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  ["rototiller_task", "Rototiller::Task::RototillerTask.define_task"].each do |_new_task_method|
    rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
task :child do |t|
  system('echo "i am the native child"')
end
task :parent => [:r_child, :child] do |t|
  system('echo "i am the native parent"')
end
Rototiller::Task::RototillerTask.define_task :r_child do |t|
  t.add_command({:name => 'echo "i am the tiller child"'})
end
Rototiller::Task::RototillerTask.define_task :r_parent => [:r_child, :child] do |t|
  t.add_command({:name => 'echo "i am the tiller parent"'})
end
  EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)

    task_name = "r_parent"
    execute_task_on(sut, task_name, rakefile_path) do |result|
      assert_match(/tiller child.*native child.*tiller parent/m, result.output, "r_parent: not all children were called")
    end
    task_name = "parent"
    execute_task_on(sut, task_name, rakefile_path) do |result|
      assert_match(/tiller child.*native child.*native parent/m, result.output, "parent: not all children were called")
    end
  end
end
