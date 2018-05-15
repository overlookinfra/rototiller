require 'fileutils'
require 'rototiller'

PCR_URI = "pcr-internal.puppet.net/slv/rototiller:latest"
LATEST_CONTAINER = "docker ps --latest --quiet"
DEFAULT_RAKE_VER = "11.0"

task :default do
  sh %{rake -T}
end

# temporary backwards compat
task :test => :'test:unit'
task :acceptance => :'test:acceptance'

namespace :test do

  desc "Run unit tests"
  rototiller_task :unit do |t|
    t.add_env({:name => 'CI', :default => 'false', :message => 'Are we in CI? If so, unit tests run in the container'})
    t.add_env({:name => 'RAKE_VER',     :default => DEFAULT_RAKE_VER,  :message => 'The rake version to use when running unit tests'})
    if ENV['CI'] && ENV['CI'] != 'false'
      Rake::Task["container:update_and_start"].execute
      t.add_command do |command|
        command.name = "docker exec --interactive `#{LATEST_CONTAINER}`"
        # use options here so they come out in order (arguments would go on the end after all options
        command.add_option({:name => '/bin/bash -l -c "'})
        command.add_option({:name => 'bundle update &&'})
        command.add_option({:name => 'bundle exec rspec --color --format documentation'})
        command.add_option do |option|
          option.name = '--pattern'
          option.add_argument do |arg|
            arg.name = "spec/**/*_spec.rb"
            arg.add_env({:name => 'SPEC_PATTERN', :message => "rspec files to test pattern"})
          end
        end
        command.add_argument({:name => '"'})
      end
      t.add_command({:name => "docker stop `#{LATEST_CONTAINER}` && docker rm `#{LATEST_CONTAINER}`"})
    else
      t.add_command do |command|
        #command.name = "bundle exec rspec --color --format documentation"
        command.name = "bundle exec rspec --color --format documentation"
        command.add_option do |option|
          option.name = '--pattern'
          option.add_argument do |arg|
            arg.name = "spec/**/*_spec.rb"
            arg.add_env({:name => 'SPEC_PATTERN', :message => "rspec files to test pattern"})
          end
        end
      end
    end
  end


  desc "Run acceptance tests in a docker container. Depends upon container:update_and_start"
  rototiller_task :acceptance => "container:update_and_start" do |t|
    t.add_env({:name => 'RAKE_VER', :default => DEFAULT_RAKE_VER,
               :message => 'The rake version to use IN unit and acceptance tests',
               })

    t.add_command({:name => "echo running acceptance tests in a container..."})
    t.add_command do |command|
      command.name = "docker exec --interactive `#{LATEST_CONTAINER}`"
      # use options here so they come out in order (arguments would go on the end after all options
      command.add_option({:name => '/bin/bash -l -c "'})
      # start sshd for beaker
      #   we have to specify group to bundle update or it fails, sometimes??
      command.add_option({:name => '/usr/sbin/sshd && bundle update &&'})
      command.add_option({:name => 'bundle exec beaker --debug --no-ntp --repo-proxy --no-validate --no-provision'})
      command.add_option do |option|
        option.name = '--keyfile'
        option.message = 'the beaker ssh id/keyfile'
        option.add_argument do |arg|
          arg.name = "/root/.ssh/docker_acceptance" # the _container's root's key, not ours!
          arg.add_env({:name => 'BEAKER_KEYFILE'})
        end
      end
      command.add_option do |option|
        option.name = '--load-path'
        option.message = 'the beaker load-path to find helpers, etc'
        option.add_argument do |arg|
          arg.name = 'acceptance/lib'
          arg.add_env({:name => 'BEAKER_LOAD_PATH'})
        end
      end
      command.add_option do |option|
        option.name = '--pre-suite'
        option.message = 'the beaker setup pre-suite files to run'
        option.add_argument do |arg|
          arg.name = 'acceptance/pre-suite'
          arg.add_env({:name => 'BEAKER_PRE_SUITE'})
        end
      end
      command.add_option do |option|
        option.name = '--hosts'
        option.message = 'The hosts file that Beaker will use'
        option.add_argument do |arg|
          arg.name = 'acceptance/hosts.cfg'
          arg.add_env({:name => 'BEAKER_HOSTS'})
        end
      end
      command.add_option do |option|
        option.name = '--tests'
        option.message = 'The path to the tests for beaker to run'
        option.add_argument do |arg|
          arg.name = 'acceptance/tests'
          arg.add_env({:name => 'BEAKER_TESTS'})
        end
      end
      command.add_argument({:name => '"'})

      puts command.to_str
    end
    t.add_command({:name => "docker stop `#{LATEST_CONTAINER}` && docker rm `#{LATEST_CONTAINER}`"})

  end

end

namespace :docs do
  YARD_DIR = 'doc'
  desc 'Clean/remove the generated documentation cache'
  task :clean do
    original_dir = Dir.pwd
    Dir.chdir( File.expand_path(File.dirname(__FILE__)) )
    sh "rm -rf #{YARD_DIR}"
    Dir.chdir( original_dir )
  end

  desc 'Generate static documentation'
  #FIXME: this is probably a build task, given that it has output files
  task :gen do
    original_dir = Dir.pwd
    Dir.chdir( File.expand_path(File.dirname(__FILE__)) )
    output = `yard doc`
    puts output
    if output =~ /\[warn\]|\[error\]/
      begin # prevent pointless stack on purposeful fail
        fail "Errors/Warnings during yard documentation generation"
      rescue Exception => e
        puts 'Yardoc generation failed: ' + e.message
        exit 1
      end
    end
    Dir.chdir( original_dir )
  end

  desc 'Check amount of documentation'
  task :check do
    original_dir = Dir.pwd
    Dir.chdir( File.expand_path(File.dirname(__FILE__)) )
    output = `yard stats --list-undoc`
    puts output
    if output =~ /\[warn\]|\[error\]/
      begin # prevent pointless stack on purposeful fail
        fail "Errors/Warnings during yard documentation generation"
      rescue Exception => e
        puts 'Yardoc generation failed: ' + e.message
        exit 1
      end
    end
    Dir.chdir( original_dir )
  end

  desc 'Generate static class/module/method graph. Calls docs:gen'
  task :class_graph => [:gen] do
    DOCS_DIR = 'docs'
    original_dir = Dir.pwd
    Dir.chdir( File.expand_path(File.dirname(__FILE__)) )
    graph_processor = 'dot'
    if exe_exists?(graph_processor)
      FileUtils.mkdir_p(DOCS_DIR)
      if system("yard graph --full | #{graph_processor} -Tpng -o #{DOCS_DIR}/rototiller_class_graph.png")
        puts "we made you a class diagram: #{DOCS_DIR}/rototiller_class_graph.png"
      end
    else
      puts 'ERROR: you don\'t have dot/graphviz; punting'
    end
    Dir.chdir( original_dir )
  end
end

namespace :container do
  desc "(re)build docker container for tests"
  rototiller_task :build do |t|
    t.add_command do |command|
      #command.name = "docker build ./ --file Dockerfile-tests --tag"
      # WARNING: this will delete any .bundle and Gemfile.lock
      # we need to delete the local bundle stuff so that when the container build slurps them up the
      #   Gemfile.lock doesn't corrupt the container bundle
      command.name = "rm -rf Gemfile.lock .bundle/ && docker build ./ --file Dockerfile-tests --tag"
      command.add_argument do |arg|
        arg.name = PCR_URI
        arg.message = 'the name of the docker image, including registry/repo'
        arg.add_env({:name => 'DOCKER_IMAGE'})
      end
    end
  end

  desc "update container's working copy; start; prep for tests."
  rototiller_task :update_and_start do |t|
    # create the container from an image in the docker daemon
    t.add_command({:name => "echo creating new container"})
    t.add_command({:name => "docker create #{PCR_URI}"})
    # get the container working copy up to date
    # (!) we can't use mounted volumes in pipelines at the moment
    t.add_command({:name => "echo 'updating container working copy...'"})
    t.add_command({:name => "docker cp --follow-link . `#{LATEST_CONTAINER}`:/rototiller"})
    t.add_command({:name => "docker start `#{LATEST_CONTAINER}`"})
    t.add_command({:name => "docker ps --latest"})
  end

  desc "push docker container for tests to Puppet Container Registry. You need to be logged into it first `docker login -u TOKEN --password <token from pcr> pcr-internal.puppet.net`"
  rototiller_task :push do |t|
    t.add_command do |command|
      command.name =  "docker push"
      command.add_argument do |arg|
        arg.name = PCR_URI
        arg.message = 'the name of the docker image, including registry/repo'
        arg.add_env({:name => 'DOCKER_IMAGE'})
      end
    end
  end
end

# Cross-platform exe_exists?
def exe_exists?(name)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{name}#{ext}")
      return true if File.executable?(exe) && !File.directory?(exe)
    }
  end
  return false
end
