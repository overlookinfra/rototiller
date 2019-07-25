# Rototiller

A [Rake](https://github.com/ruby/rake) helper library for command-oriented tasks.

## Rototiller Goals
* Reduce effort required to write first-class rake tasks
* Reduce time and effort to understand how to run rake tasks
* Simplifies the building of command strings in :rototiller_task for task authors
* Abstracts the overriding of command string components: commands, switches, options, arguments for task users
* Unifies and standardizes messaging surrounding the use of environment variables for task operations
* Reduce duplication in Rakefiles across projects

<a name="install"></a>
## Install
    gem install rototiller

<a name="write"></a>
## Write
Rototiller provides a Rake DSL addition called '[rototiller_task](docs/rototiller_task_reference.md)' which is a fully featured Rake task with environment variable handling, messaging and command-string-building functionality.

Rototiller has 4 main _types_ of arguments that can be passed to a command in a task. `RototillerTasks` can accept multiple commands.  Each of these argument types has a similar API that looks similar to `#add_command`.

<a name="use"></a>
## Use
It's just like normal Rake. We just added a bunch of environment variable handling and messaging!
(with the below example Rakefile):

    $) rake -T
    rake child        # override command-name with environment variable
    rake parent_task  # parent task for dependent tasks

    $) rake -D
    rake child
        override command-name with environment variable

    rake parent_task
        parent task for dependent tasks. this one also uses two environment variables and two commands

### The old way

    desc 'the old, bad way. This is for the README.md file.'
      task :demo_old do |t|
        echo_args = ENV['COMMAND_NAME'] || "my_sweet_command #{ENV['HOME']}"
        overriding_options = ENV['OPTIONS'].to_s
        args = [echo_args, *overriding_options.split(' '), '--switch'].compact
        sh("echo", *args)
      end

this does, _mostly_ the same as below.  but what do the various environment variables do?  they aren't documented anywhere, especially in Rake's output. why do we have to split on a space for the overriding options?  why do we compact?  We shouldn't have to do this in all our Rakefiles, and then forget to do it, _correctly_ in most.  Rototiller does all this for us, but uniformly handling environment variables for any command piece, optionally. But anytime we do, we automatically get messaging in Rake's output, and this can be controlled with Rake's --verbose flag.  Now we don't have to dig into the Rakefile to see what the author intended for an interface.  Now we can provide a uniform interface for our various tasks based upon this library and have messaging come along for the ride.  Now we can remove the majority of repeated code from our Rakefiles.

### The rototiller way

    require 'rototiller'
    desc 'the new, rototiller way. This is for the README.md file.'
      rototiller_task :demo_new do |t|
        t.add_env({:name => 'FOO', :message => 'I am describing FOO, my task needs me, but has a default. this default will be set in the environment unless it exists', :default => 'FOO default'})
        t.add_env do |e|
          e.name    = 'HOME'
          e.message = 'I am describing HOME, my task needs me. all rototiller methods can take a hash or a block'
        end

        t.add_command do |c|
          c.name = 'echo my_sweet_command ${HOME}'
          c.add_env({:name => 'COMMAND_NAME', :message => 'use me to override this command name (`echo my_sweet_command`)'})
          # anti-pattern: this is really an option.  FIXME once add_option is implemented
          c.add_switch({:name => '--switch ${FOO}'})
          # FYI, add_switch can also take a block and add_env
          # command blocks also have add_option, and add_arg, each of which can add environment variables which override themselves.
          # add_option actually has its own add_arg and each of those have add_env.  so meta
        end
      end

### Reference
* [rototiller\_task reference](docs/rototiller_task_reference.md)
  * contains usage information on all rototiller_task API methods

## More Documentation

Rototiller is documented using yard
* [Rototiller's Yard Docs](http://www.rubydoc.info/github/puppetlabs/rototiller) (API/internal Architecture docs)

## Contributing
* [Contributing](CONTRIBUTING.md)  do not merge, blah, trying review functions in github

## Issues

* none. it's perfect, but just in case:
  * [Jira: Rototiller](https://tickets.puppetlabs.com/issues/?jql=project%20%3D%20QA) (sorry, this is Puppet-internal for now)
  * [Puppet QA-team](mailto:qa-team@puppet.com)
