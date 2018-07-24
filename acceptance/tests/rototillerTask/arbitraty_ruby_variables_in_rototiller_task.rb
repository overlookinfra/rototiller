require "beaker/hosts"
require "rakefile_tools"
require "test_utilities"

test_name "Set arbitrary ruby variables in rototiller tasks" do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  @block_syntax = "block_syntax"
  @hash_syntax = "hash_syntax"

  local_ruby_var = "local_ruby_var"
  instance_ruby_var = "instance_ruby_var"

  instance_regex = /--local #{local_ruby_var}/
  local_regex = /--instance #{instance_ruby_var}/

  rakefile_contents = <<-EOS
#{rototiller_rakefile_header}

@instance_ruby_var = '#{instance_ruby_var}'

Rototiller::Task::RototillerTask.define_task :#{@block_syntax} do |t|

  local_ruby_var = '#{local_ruby_var}'

  t.add_command do |c|
    c.name = 'echo'

    c.add_option do |o|
      o.name = '--local'
      o.add_argument do |env|
        env.name = local_ruby_var
      end
    end
    c.add_option do |o|
      o.name = '--instance'
      o.add_argument do |env|
        env.name = @instance_ruby_var
      end
    end
  end
end

Rototiller::Task::RototillerTask.define_task :#{@hash_syntax} do |t|

  local_ruby_var = '#{local_ruby_var}'

  t.add_command do |c|
    c.name = 'echo'

    c.add_option do |o|
      o.name = '--local'
      o.add_argument({:name => local_ruby_var})
    end
    c.add_option do |o|
      o.name = '--instance'
      o.add_argument({:name => @instance_ruby_var})
    end
  end
end
  EOS
  rakefile_path = create_rakefile_on(sut, rakefile_contents)

  step "Run rake task defined in block syntax" do
    execute_task_on(sut, @block_syntax, rakefile_path) do |result|
      assert_match(instance_regex, result.stdout, "The arbitrary instance variable was not observed with block syntax")
      assert_match(local_regex, result.stdout, "The arbitrary local variable was not observed with block syntax")
    end
  end

  step "Run rake task with add_option defined as a hash" do
    execute_task_on(sut, @hash_syntax, rakefile_path) do |result|
      assert_match(local_regex, result.stdout, "The arbitrary local variable was not observed with hash syntax")
      assert_match(instance_regex, result.stdout, "The arbitrary instance variable was not observed with hash syntax")
    end
  end
end
