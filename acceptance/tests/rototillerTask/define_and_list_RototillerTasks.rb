require "beaker/hosts"
require "rakefile_tools"
require "test_utilities"

test_name "C97830: describe and list RototillerTasks" do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  @task_body_string = "Lorem ipsum dolor sit amet"
  def create_rakefile_task_segment(options)
    description = "desc '#{options[:init_method]} #{options[:description]}'" if options[:description]
    if options[:init_method] == :dsl
      method = "rototiller_task"
    else
      method = "Rototiller::Task::RototillerTask.#{options[:init_method]}"
    end

    segment = <<-EOS
#{description}
#{method} :#{options[:init_method]}#{options[:description]} do |t|
  puts '#{options[:init_method]}#{options[:description]} #{@task_body_string} '
end
EOS
  end

  tasks = [
    { init_method: "define_task", description: nil },
    { init_method: "define_task", description: "yep" },
    { init_method: "new", description: nil },
    { init_method: "new", description: "yep" },
    { init_method: :dsl, description: nil },
    { init_method: :dsl, description: "yep" }
  ]

  rakefile_contents = rototiller_rakefile_header

  tasks.each do |task|
    rakefile_contents += create_rakefile_task_segment(task)
  end

  rakefile_path = create_rakefile_on(sut, rakefile_contents)

  tasks.each do |task|
    step "Use the -T rake switch to test task '#{task[:task_name]}' description" do
      on(sut, "rake -T --rakefile #{rakefile_path}", accept_all_exit_codes: true) do |result|
        assert(result.exit_code == 0, "The expected exit code 0 was not observed")
        assert_no_match(/error/i, result.output, "An unexpected error was observed")
        if task[:description]
          assert_match(/#{task[:init_method]}#{task[:description]}/, result.stdout, "The correct description '#{task[:init_method]}#{task[:description]}' was not observed")
        else
          assert_match(/#{task[:init_method]}\s+ # RototillerTask/, result.stdout, "The correct description '#{task[:init_method]}' was not observed")
        end
      end
    end

    execute_task_on(sut, "#{task[:init_method]}#{task[:description]}", rakefile_path) do |result|
      assert_match(/#{options[:init_method]}#{options[:description]} #{@task_body_string}/, result.stdout, "The expected output from the task '#{options[:init_method]}#{options[:description]}' was not observed")
    end
  end
end
