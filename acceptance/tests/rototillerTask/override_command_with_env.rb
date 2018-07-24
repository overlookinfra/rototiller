require "beaker/hosts"
require "rakefile_tools"
require "test_utilities"

test_name "C97827: can set envvar to override command name when using task.command" do
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  # FIXME: this needs to use rakefile_segment and a single upload of the single rakefile

  @task_name = "commands_with_override"
  step "add_env does not override when missing" do
    override_env = "BROCKSAMSON0"
    validation_string = random_string
    env_value = "echo " << validation_string

    rakefile_contents = <<-EOS
      #{rototiller_rakefile_header}
      Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
          t.add_command({:name => 'echo fail', :add_env => {:name => '#{override_env}'}})
      end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)
    sut.add_env_var(override_env, env_value)

    execute_task_on(sut, @task_name, rakefile_path) do |result|
      # command was used that was supplied by the override_env
      assert_match(validation_string, result.stdout, "The correct command was not observed")
    end
  end

  step "add_env as hash in command hash" do
    override_env = "BROCKSAMSON1"
    validation_string = random_string
    env_value = "echo " << validation_string

    rakefile_contents = <<-EOS
      #{rototiller_rakefile_header}
      Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
          t.add_command({:name => 'nonesuch', :add_env => {:name => '#{override_env}'}})
      end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)
    sut.add_env_var(override_env, env_value)

    execute_task_on(sut, @task_name, rakefile_path) do |result|
      # command was used that was supplied by the override_env
      assert_match(/^#{validation_string}/, result.stdout, "The correct command was not observed")
    end
  end

  step "add_env as block in command block" do
    override_env = "BROCKSAMSON2"
    validation_string = random_string
    env_value = "echo " << validation_string

    rakefile_contents = <<-EOS
      #{rototiller_rakefile_header}
      Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
        t.add_command do |c|
          c.name = 'nonesuch'
          c.add_env do |e|
            e.name = '#{override_env}'
          end
        end
      end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)
    sut.add_env_var(override_env, env_value)

    execute_task_on(sut, @task_name, rakefile_path) do |result|
      assert_match(/^#{validation_string}/, result.stdout, "The correct command was not observed")
    end
  end

  step "add_env as hash in command block" do
    override_env = "BROCKSAMSON3"
    validation_string = random_string
    env_value = "echo " << validation_string

    rakefile_contents = <<-EOS
      #{rototiller_rakefile_header}
      Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
          t.add_command do |c|
            c.name = 'nonesuch'
            c.add_env({:name => '#{override_env}'})
          end
      end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)
    sut.add_env_var(override_env, env_value)

    execute_task_on(sut, @task_name, rakefile_path) do |result|
      assert_match(/^#{validation_string}/, result.stdout, "The correct command was not observed")
    end
  end

  step "add_env multiples as both hash and block" do
    override_env = "BROCKSAMSON4"
    override_env2 = "BROCKSAMSON5"
    validation_string = random_string
    validation_string2 = random_string
    env_value = "echo " << validation_string
    env_value2 = "echo " << validation_string2

    rakefile_contents = <<-EOS
      #{rototiller_rakefile_header}
      Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
          t.add_command do |c|
            c.name = 'nonesuch'
            c.add_env({:name => '#{override_env}'})
            c.add_env do |e|
              e.name = '#{override_env2}'
            end
          end
      end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)
    sut.add_env_var(override_env, env_value)
    sut.add_env_var(override_env2, env_value2)

    execute_task_on(sut, @task_name, rakefile_path) do |result|
      assert_match(/^#{validation_string2}/, result.stdout, "The correct command was not observed")
    end
  end
end
