require 'beaker/hosts'
require 'rakefile_tools'
require 'test_utilities'

# QA-2851
test_name 'allows pry/interaction in rototiller_task subprocess command' do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  test_name     = File.basename( __FILE__, ".*" )
  @task_name    = test_name

  step 'install pry' do
    on(sut, 'gem install pry')
  end

  step 'create rototillerTask where ruby executes a line with pry' do
    rakefile_contents = <<-EOS
rototiller_task :#{@task_name} do |t|
  t.add_command({:name => 'ruby -e "puts :first; require \\'pry\\'; binding.pry; puts :second"'})
end
    EOS

    rakefile_path = create_rakefile_on(sut, rakefile_contents)
    matcher = /".*\n.*first.*pry.*quit.*second/m
    if sut['platform'] =~ /osx/
      matcher = /first\n.*second/
    end
    execute_task_on(sut, @task_name, rakefile_path, {:stdin => "quit\n"}) do |result|
      assert_match(matcher, result.stdout, 'did not see pry in the output')
    end
  end
end
