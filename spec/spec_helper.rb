# frozen_string_literal: true

def is_ci?
  ENV["CI"] || ENV["JENKINS_URL"] || ENV["TRAVIS"] || ENV["APPVEYOR"]
end

unless ENV["COVERAGE"] && !ENV["COVERAGE"].to_s.casecmp("true").zero? &&
       !ENV["COVERAGE"].to_s.casecmp("yes").zero? &&
       !ENV["COVERAGE"].to_s.casecmp("on").zero?

  # coveralls prevents local simplecov from running (facepalm)
  if is_ci?
    # https://coveralls.io/github/puppetlabs/doctor_teeth
    require "coveralls"
    Coveralls.wear!
  end

  require "simplecov"
  SimpleCov.start do
    add_filter "/spec/"
    add_filter ".bundle/gems"
  end
end

require 'rspec'
require 'rototiller'

def random_string
  (0...10).map { ('a'..'z').to_a[rand(26)] }.join
end

def set_random_env
  name = unique_env
  ENV[name] = random_string
  return name
end

def unique_env
  env = random_string
  env = random_string until !ENV[env]
  return env
end

def with_captured_stdout
  begin
    old_stdout = $stdout
    $stdout = StringIO.new('','w')
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end
end

RSpec.configure do |config|
  config.include Rake::DSL
end
