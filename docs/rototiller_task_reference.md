# Rototiller Task Reference
* herein lies the reference to the rototiller_task API

* [rototiller_task](#rototiller_task)
  * [#add_env](#rototiller_task-add_env)
  * [#add_command](#rototiller_task-add_command)
  * [Command](#Command)
    * [#add\_env](#Command-add_env)
    * [#add\_switch](#Command-add_switch)
      * [#add\_env](#Command-add_switch-add_env)
    * [#add\_option](#Command-add_option)
      * [#add\_env](#Command-add_option-add_env)
      * [#add\_argument](#Command-add_option-add_argument)
        * [#add\_env](#Command-add_option-add_argument-add_env)
    * [#add\_argument](#Command-add_argument)
      * [#add\_env](#Command-add_argument-add_env)

<a name="rototiller_task"></a>
## rototiller_task
* behaves just like any other rake task name (see below)

<a name="rototiller_task-add_env"></a>
### #add_env
* parent methods such as `add_command`, `add_argument`, `add_switch`, and  `add_option` can utilize the method `add_env` to add an env to a param
* adds an arbitrary environment variable for use in the task
* If the parent does call the `name=` method and the method `default=` is not called under `add_env` the value passed to `name=` is the default
* If the parent does not call the `name=` method and the method `default=` is called under `add_env` the value passed to `default=` is the default
* If the parent does not call the `name=` method and the method `name=` is called under `add_env` the task will only continue if a value is found in the environment
* if specified with a default value, and the system environment does not have this variable set, rototiller will set it, for later use in a task or otherwise
* the same method can be used for any portion of a [command](#Command-add_env) as well, including command name, options, option arguments, switches, and command arguments.  In these cases the environment variable's value will override that portion of the command string.
* more add_env use cases can be seen in the [env\_var\_example\_reference](env_var_example_reference.md)

#### Environment Variable and Task/Command Interactions

| has default?  | exists in ENV? | rototiller creates | rototiller stops |
| ------------  | -------------- | ------------------ | ---------------- |
|      n        |       n        |        n           |         y        |
|      n        |       y        |        n           |         n        |
|      y        |       n        |        y           |         n        |
|      y        |       y        |        n           |         n        |

<a name="rototiller_task-add_command"></a>
### #add_command
* adds a command to a rototiller_task. This command can in turn contain environment variables, switches, options and arguments
* this command (and any others) will be run with the task is executed
* (!) currently a task will fail if its command fails _only_ if `#fail_on_error` is set
  * the error message from the command will only be shown when rake is run with `--verbose`
  * this will be fixed post-1.0

&nbsp;

    require 'rototiller'

    desc "parent task for dependencies test. this one also uses an environment variable"
    rototiller_task :parent_task do |task|
      # most methods take either a hash, or block syntax (see next task)
      ENV['HAS_VALUE_NO_DEFAULT'] = 'from environment'
      task.add_env({:name     => 'HAS_VALUE_NO_DEFAULT'})
      # rototiller will set this in the environment so the task, programs, can use it
      task.add_env({:name     => 'NO_VALUE_HAS_DEFAULT',  :default => 'default value'})
      ENV['HAS_VALUE_HAS_DEFAULT'] = 'from environment'
      task.add_env({:name     => 'HAS_VALUE_HAS_DEFAULT', :default => 'default value'})
      task.add_command({:name => 'echo NO_VALUE_NO_DEFAULT:  "$NO_VALUE_NO_DEFAULT"'})
      task.add_command({:name => 'echo HAS_VALUE_NO_DEFAULT:  \"$HAS_VALUE_NO_DEFAULT\"'})
      task.add_command({:name => 'echo NO_VALUE_HAS_DEFAULT:  \"$NO_VALUE_HAS_DEFAULT\"'})
      task.add_command({:name => 'echo HAS_VALUE_HAS_DEFAULT: \"$HAS_VALUE_HAS_DEFAULT\"'})
    end

produces:

    # added environment variable defaults are set, implicitly, if not found
    #   this way, their value can be used in the task
    $) rake parent_task
    [I] 'HAS_VALUE_NO_DEFAULT': using system: 'from environment', no default; ''
    [I] 'NO_VALUE_HAS_DEFAULT': using default: 'default value'; ''
    [I] 'HAS_VALUE_HAS_DEFAULT': using system: 'from environment', default: 'default value'; ''
    echo NO_VALUE_NO_DEFAULT:  "$NO_VALUE_NO_DEFAULT"
    NO_VALUE_NO_DEFAULT:
    echo HAS_VALUE_NO_DEFAULT:  \"$HAS_VALUE_NO_DEFAULT\"
    HAS_VALUE_NO_DEFAULT: "from environment"
    echo NO_VALUE_HAS_DEFAULT:  \"$NO_VALUE_HAS_DEFAULT\"
    NO_VALUE_HAS_DEFAULT: "default value"
    echo HAS_VALUE_HAS_DEFAULT: \"$HAS_VALUE_HAS_DEFAULT\"
    HAS_VALUE_HAS_DEFAULT: "from environment"

&nbsp;

<a name="Command"></a>
## Command
<a name="Command-add_env"></a>
### #add_env
* adds an arbitrary environment variable which overrides the name of the command
* if specified with a default value, and the system environment does not have this variable set, rototiller will set it, for later use in a task or otherwise
* more add_env use cases can be seen in the [env\_var\_example\_reference](env_var_example_reference.md)

&nbsp;

    desc "override a command-name with environment variable"
    rototiller_task :child => :parent_task do |task|
      task.add_command({:name => 'nonesuch', :add_env => {:name => 'COMMAND_EXE1'}})
      # block syntax here. We give up some lines for more readability
      task.add_command do |cmd|
        cmd.name = 'meneither'
        cmd.add_env({:name => 'COMMAND_EXE2'})
      end
    end

produces:

    # we didn't override the command with its env_var, so shell complains about nonsuch and exits
    $) be rake -f docs/Rakefile.
    example child

    nonesuch
      [I] 'COMMAND_EXE1': using default: 'nonesuch'; ''
      No such file or directory - nonesuch
      nonesuch
        [I] 'COMMAND_EXE1': using default: 'nonesuch'; ''

    # now we've overridden the first command to echo partial success
    #  but the next command was not overridden by its environment variable, which has no default
    $) be rake -f docs/Rakefile.example child COMMAND_EXE1="echo i work now" COMMAND_EXE2="but not i"

    echo i work now
      [I] 'COMMAND_EXE1': using system: 'echo i work now', default: 'nonesuch'; ''
      i work now
      but not i
        [I] 'COMMAND_EXE2': using system: 'but not i', default: 'meneither'; ''
        No such file or directory - but
        but not i
          [I] 'COMMAND_EXE2': using system: 'but not i', default: 'meneither'; ''

<a name="Command-add_switch"></a>
### #add_switch
<a name="Command-add_argument"></a>
### #add_argument
* adds an arbitrary string to a command
  * intended to add `--switch` type binary switches that do not take arguments (see [add_option](#Command:add_option))
  * add\_argument is intended to add strings to the end of the command string (options and switches are added prior to arguments

<a name="Command-add_switch-add_env"></a>
<a name="Command-add_argument-add_env"></a>
#### #add_env
* just like the other `#add_env` methods for other portions of a Command
* adds an arbitrary environment variable which overrides the name of the switch or argument
* if specified with a default value, and the system environment does not have this variable set, rototiller will set it, for later use in a task or otherwise
* more add_env use cases can be seen in the [env\_var\_example\_reference](env_var_example_reference.md)

<a name="Command-add_option"></a>
### #add_option

<a name="Command-add_option-add_env"></a>
#### #add_env
* adds an arbitrary environment variable which overrides the name of the option (usually the thing with the --)
* just like the other `#add_env` methods for other portions of a Command
* more add_env use cases can be seen in the [env\_var\_example\_reference](env_var_example_reference.md)

<a name="Command-add_option-add_argument"></a>
#### #add_argument
* adds an arbitrary string to trail an option (aka: an option argument)

<a name="Command-add_option-add_argument-add_env"></a>
##### #add_env
* adds an arbitrary environment variable which overrides the name of _argument_ of this option
* just like the other `#add_env` methods for other portions of a Command
* more add_env use cases can be seen in the [env\_var\_example\_reference](env_var_example_reference.md)

&nbsp;

    desc "add command-switch or option or argument with overriding environment variables"
    rototiller_task :variable_switch do |task|
      task.add_command do |cmd|
        cmd.name = 'echo command_name'
        cmd.add_switch do |s|
          s.name = '--switch'
          s.add_env({:name => 'CRASH_OVERRIDE'})
        end
        cmd.add_argument do |a|
          a.name = 'arguments go last'
          a.add_env({:name => 'ARG_OVERRIDE2'})
        end
        cmd.add_option do |o|
          o.name = '--option'
          o.add_env({:name => 'OPT_OVERRIDE'})
          o.add_argument do |arg|
            arg.name = 'argument'
            arg.add_env({:name => 'ARG_OVERRIDE', :message => 'message at the env for argument'})
          end
        end
      end
    end

produces:

    $) rake -f docs/Rakefile.example variable_switch
    echo command_name --switch --option argument arguments go last
      using `echo` to show how to override command portions using environment vars
      [I] 'CRASH_OVERRIDE': using default: '--switch'; 'this env overrides `switch`'
      [I] 'OPT_OVERRIDE': using default: '--option'; 'this env overrides --option'
      [I] 'OPT_ARG_OVERRIDE': using default: 'argument'; 'message at the env for option argument'

      [I] 'ARG_OVERRIDE': using default: 'arguments go last'; 'this env overrides `arguments go last`'
    command_name --switch --option argument arguments go last

    $) rake --rakefile docs/Rakefile.example variable_switch CRASH_OVERRIDE='and burn'
    echo command_name and burn --option argument arguments go last
      using `echo` to show how to override command portions using environment vars
      [I] 'CRASH_OVERRIDE': using system: 'and burn', default: '--switch'; 'this env overrides `switch`'
      [I] 'OPT_OVERRIDE': using default: '--option'; 'this env overrides --option'
      [I] 'OPT_ARG_OVERRIDE': using default: 'argument'; 'message at the env for option argument'

      [I] 'ARG_OVERRIDE': using default: 'arguments go last'; 'this env overrides `arguments go last`'
    command_name and burn --option argument arguments go last

    $) rake --rakefile docs/Rakefile.example variable_switch OPT_OVERRIDE='--real_option'
    echo command_name --switch --real_option argument arguments go last
      using `echo` to show how to override command portions using environment vars
      [I] 'CRASH_OVERRIDE': using default: '--switch'; 'this env overrides `switch`'
      [I] 'OPT_OVERRIDE': using system: '--real_option', default: '--option'; 'this env overrides --option'
      [I] 'OPT_ARG_OVERRIDE': using default: 'argument'; 'message at the env for option argument'

      [I] 'ARG_OVERRIDE': using default: 'arguments go last'; 'this env overrides `arguments go last`'
    command_name --switch --real_option argument arguments go last

    $) rake --rakefile docs/Rakefile.example variable_switch ARG_OVERRIDE='opt arg'
    echo command_name --switch --option argument opt arg
      using `echo` to show how to override command portions using environment vars
      [I] 'CRASH_OVERRIDE': using default: '--switch'; 'this env overrides `switch`'
      [I] 'OPT_OVERRIDE': using default: '--option'; 'this env overrides --option'
      [I] 'OPT_ARG_OVERRIDE': using default: 'argument'; 'message at the env for option argument'

      [I] 'ARG_OVERRIDE': using system: 'opt arg', default: 'arguments go last'; 'this env overrides `arguments go last`'
    command_name --switch --option argument opt arg

    # what do you think ARG_OVERRIDE2 does?
