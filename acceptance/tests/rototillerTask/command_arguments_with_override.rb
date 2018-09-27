require "beaker/hosts"
require "rakefile_tools"
require "test_utilities"

test_name "C97824: can set command arguments and overrides in a RototillerTask" do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  # FIXME: this is almost verbatim command_switches.rb.  abstract me
  test_filename = File.basename(__FILE__, ".*")
  rakefile_contents = ""

  tasks = []
  step "add_argument does its thing" do
    task_name = test_filename + tasks.length.to_s

    rakefile_contents << <<-EOS
      rototiller_task :#{task_name} do |t|
          t.add_command({:name => 'echo', :add_argument => {:name => '#{task_name}'}})
      end
    EOS
    tasks << task_name
  end

  step "add_env does not override when missing" do
    task_name    = test_filename + tasks.length.to_s
    override_env = test_filename.upcase + random_string

    rakefile_contents << <<-EOS
      rototiller_task :#{task_name} do |t|
          t.add_command({:name => 'echo', :add_argument => {:name => '#{task_name}', :add_env => {:name => '#{override_env}'}}})
      end
    EOS
    tasks << task_name
  end

  step "add_env with value as hash in command hash" do
    override_env = test_filename.upcase + random_string
    validation_string = random_string
    task_name = validation_string
    env_value = validation_string

    rakefile_contents << <<-EOS
      rototiller_task :#{task_name} do |t|
          t.add_command({:name => 'echo', :add_argument => {:name => '#{task_name}', :add_env => {:name => '#{override_env}'}}})
      end
    EOS
    tasks << task_name
    sut.add_env_var(override_env, env_value)
  end

  step "add_env with value as blocks on blocks on blocks" do
    override_env = test_filename.upcase + random_string
    validation_string = random_string
    task_name = validation_string
    env_value = validation_string

    rakefile_contents << <<-EOS
      rototiller_task :#{task_name} do |t|
        t.add_command do |c|
          c.name = 'echo'
          c.add_argument do |s|
            s.name = 'fail'
            s.add_env do |e|
              e.name = '#{override_env}'
            end
          end
        end
      end
    EOS
    tasks << task_name
    sut.add_env_var(override_env, env_value)
  end

  step "add_env with value as hash in hash in block" do
    override_env = test_filename.upcase + random_string
    validation_string = random_string
    task_name = validation_string
    env_value = validation_string

    rakefile_contents << <<-EOS
      rototiller_task :#{task_name} do |t|
          t.add_command do |c|
            c.name = 'echo'
            c.add_argument({:name => 'fail', :add_env => {:name => '#{override_env}'}})
          end
      end
    EOS
    tasks << task_name
    sut.add_env_var(override_env, env_value)
  end

  step "add_env with value as hash in block in block" do
    override_env = test_filename.upcase + random_string
    validation_string = random_string
    task_name = validation_string
    env_value = validation_string

    rakefile_contents << <<-EOS
      rototiller_task :#{task_name} do |t|
        t.add_command do |c|
          c.name = 'echo'
          c.add_argument do |s|
            s.name = 'fail'
            s.add_env({:name => '#{override_env}'})
          end
        end
      end
    EOS
    tasks << task_name
    sut.add_env_var(override_env, env_value)
  end

  step "add_argument multiples as both hash and block" do
    # FIXME: this one can't check for the second switch with the assertions below
    validation_string  = random_string
    validation_string2 = random_string
    task_name = validation_string

    rakefile_contents << <<-EOS
      rototiller_task :#{task_name} do |t|
          t.add_command do |c|
            c.name = 'echo'
            c.add_argument({:name => '#{validation_string}'})
            c.add_argument do |s|
              s.name = '#{validation_string2}'
            end
          end
      end
    EOS
    tasks << task_name
  end

  step "create Rakefile, execute tasks" do
    rakefile_path = create_rakefile_on(sut, rakefile_contents)

    tasks.each do |task|
      execute_task_on(sut, task, rakefile_path) do |result|
        assert_match(/^#{task}/, result.stdout, "The correct switch was not observed (#{task})")
      end
    end
  end
end
