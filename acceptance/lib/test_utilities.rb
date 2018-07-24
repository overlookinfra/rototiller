module TestUtilities
  def random_string
    # used in task names, don't put numbers in me
    [*("a".."z")].sample(8).join
  end

  def set_random_env_on(host)
    name = unique_env_on(host)
    host.add_env_var(name, random_string)
    name
  end

  def unique_env_on(host)
    env = {}
    env_var = random_string

    # pars out the env on the sut
    on(host, "printenv") do |r|
      r.stdout.split("\n").each do |line|
        l = line.split("=")
        env[l.first] = l.last
      end
    end
    env_var = random_string while env[env_var]
    env_var
  end

  def execute_task_on(host, task_name = nil, rakefile_path = nil, opts = {})
    if opts[:accept_all_exit_codes]
      step "Execute task '#{task_name}'"
    else
      step "Execute task '#{task_name}', ensure success"
    end

    command = "rake #{task_name}"
    command += " --verbose" if opts[:verbose]
    command += " --rakefile #{rakefile_path}" if rakefile_path
    on(host, command, opts) do |result|
      unless opts[:accept_all_exit_codes]
        acceptable_exit_codes = opts[:acceptable_exit_codes] || 0
        acceptable_exit_codes = [acceptable_exit_codes] unless acceptable_exit_codes.is_a?(Array)
        assert(acceptable_exit_codes.include?(result.exit_code), "Unexpected exit code: #{result.exit_code}")
        assert_no_match(/error/i, result.output, "An unexpected error was observed: '#{result.output}'")
      end
      yield result if block_given?
      return result
    end
  end

  RESERVED_KEYS = %i[block_syntax env_value exists type].freeze
  def remove_reserved_keys(h)
    hash = h.dup
    RESERVED_KEYS.each do |key|
      hash.delete(key)
    end
    hash
  end
end
