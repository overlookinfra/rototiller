# a bunch of utilities for acceptance testing with beaker
module TestUtilities
  def random_string
    # used in task names, don't put numbers in me
    [*("a".."z")].sample(8).join
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
    print_test_step(task_name, opts)
    command = "rake #{task_name}"
    command += " --verbose" if opts[:verbose]
    command += " --rakefile #{rakefile_path}" if rakefile_path
    result = on(host, command, opts)
    validate_task_results(result, opts) unless opts[:accept_all_exit_codes]
    yield result if block_given?
    result
  end

  RESERVED_KEYS = %i[block_syntax env_value exists type].freeze
  def remove_reserved_keys(h)
    hash = h.dup
    RESERVED_KEYS.each do |key|
      hash.delete(key)
    end
    hash
  end

  private

  # @api private
  def print_test_step(task_name, opts)
    if opts[:accept_all_exit_codes]
      step "Execute task '#{task_name}'"
    else
      step "Execute task '#{task_name}', ensure success"
    end
  end

  # @api private
  def validate_task_results(result, opts)
    assert(acceptable_exit_codes(opts).include?(result.exit_code),
           "Unexpected exit code: #{result.exit_code}")
    assert_no_match(/error/i, result.output,
                    "An unexpected error was observed: '#{result.output}'")
  end

  # @api private
  def acceptable_exit_codes(opts)
    acceptable_exit_codes = opts[:acceptable_exit_codes] || 0
    [acceptable_exit_codes].flatten
  end
end
