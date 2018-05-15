require 'beaker/hosts'
require 'rakefile_tools'
require 'test_utilities'

test_name 'An ENV should be able to stop when attached to a switch' do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  # an env without a default should stop the task
  stopping_env = {:name => 'STOP', :message => 'I will stop the task'}
  sut.clear_env_var(stopping_env[:name])

  @block_syntax = 'block_syntax'

  block_body = {
    :add_command => {
      :name => 'echo RUNNING',
      :add_switch => { :add_env => stopping_env }
    }
  }

  rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
Rototiller::Task::RototillerTask.define_task :#{@block_syntax} do |x|
  #{RototillerBodyBuilder.new(block_body)}
end
  EOS
  rakefile_path = create_rakefile_on(sut, rakefile_contents)

  #add env to command
  step 'Run rake task defined in block syntax, ENV not set' do
    execute_task_on(sut, @block_syntax, rakefile_path, :accept_all_exit_codes => true) do |result|

      assert_no_match(/RUNNING/, result.stdout, "The command ran when it wasn't expected to")

      rototiller_output_regex = /\[E\] required: .*#{stopping_env[:name]}.*#{stopping_env[:message]}/
      assert_msg = 'The expected output was not observed'
      assert_match(rototiller_output_regex, result.stdout, assert_msg)
      assert(result.exit_code == 1, 'The expected error message was not observed')
    end
  end
end
