source 'https://rubygems.org'
require 'rubygems'
# place all development, system_test, etc dependencies here

def location_for(place, fake_version = nil)
  if place =~ /^(git:[^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

# lint/unit tests
# runs in travis with: bundle install --without system_tests development
rake_version                = "~> 12"
flay_version                = "~> 2.10.0"
flog_version                = "~> 4.2.0"
rubocop_version             = "~> 0.55"
tins_version                = "~> 1"
term_ansicolor_version      = "~> 1"
kramdown_version            = "~> 1"
parser_version              = "~> 2"
if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0.0')
  rake_version              = "< 11"
  flay_version              = "~> 2.4.0"
  flog_version              = "~> 4.2.0"
  rubocop_version           = "~> 0.40.0"
  tins_version              = "~> 1.6.0"
  term_ansicolor_version    = "~> 1.3.2"
  kramdown_version          = "~> 1.14.0"
  parser_version            = "~> 2.4.0.2"
end
gem 'rake',                 "#{rake_version}"
gem "rototiller",           *location_for(ENV['TILLER_VERSION'] || '~> 1.0')
gem 'rspec',                '~> 3.4.0'
gem "rubocop",              "#{rubocop_version}"
gem "simplecov",            "~> 0.14.0" # used in tests
gem "yardstick",            "~> 0.9.0"  # used in tests
gem 'markdown',             '~> 0'
gem "flay",                 "#{flay_version}"
gem "flog",                 "#{flog_version}"
gem "roodi",                "~> 5.0.0"  # used in tests
gem "rubycritic"
gem "tins",                 "#{tins_version}"
gem "term-ansicolor",       "#{term_ansicolor_version}"
gem "kramdown",             "#{kramdown_version}"
gem "parser",               "#{parser_version}"
# https://coveralls.io/github/puppetlabs/doctor_teeth
gem "coveralls"

group :system_tests do
  beaker_version     = '~> 3.0'
  nokogiri_version   = '~> 1' # any
  public_suffix_version = '~> 1' # any
  activesupport_version = '~> 1' # any
  # restrict gems to enable ruby versions
  #   nokogiri comes along for the ride but needs some restriction too
  if Gem::Version.new(RUBY_VERSION).between?(Gem::Version.new('2.1.6'),Gem::Version.new('2.4.9'))
    beaker_version   = '<  3.9.0'
    nokogiri_version = '<  1.7.0'
  elsif Gem::Version.new(RUBY_VERSION).between?(Gem::Version.new('2.0.0'),Gem::Version.new('2.1.5'))
    beaker_version   = '<  3.1.0'
    nokogiri_version = '<  1.7.0'
  elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0.0')
    beaker_version   = '~> 2.0'
    nokogiri_version = '<  1.7.0'
    public_suffix_version = '<  1.5.0'
    activesupport_version = '<  5.0.0'
  end
  gem 'beaker'               ,"#{beaker_version}"
  gem 'beaker-hostgenerator'
  gem "beaker-abs", *location_for(ENV['BEAKER_ABS_VERSION'] || "~> 0.2")
  gem 'nokogiri'             ,"#{nokogiri_version}"
  gem 'public_suffix'        ,"#{public_suffix_version}"
  gem 'activesupport'        ,"#{activesupport_version}"
end

local_gemfile = "#{__FILE__}.local"
if File.exists? local_gemfile
  eval(File.read(local_gemfile), binding)
end

user_gemfile = File.join(Dir.home,'.Gemfile')
if File.exists? user_gemfile
  eval(File.read(user_gemfile), binding)
end
