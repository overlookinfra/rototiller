# coding: utf-8

# place ONLY runtime dependencies in here (in addition to metadata)
require File.expand_path("../lib/rototiller/version", __FILE__)

Gem::Specification.new do |s|
  s.name          = "rototiller"
  s.authors       = ["Puppet, Inc.", "Zach Reichert", "Eric Thompson"]
  s.email         = ["qa@puppet.com"]
  s.summary       = "Puppet Labs rake tool"
  s.description   = "Puppet Labs tool for building rake tasks"
  s.homepage      = "https://github.com/puppetlabs/rototiller"
  s.version       = Rototiller::Version::STRING
  s.license       = "Apache-2.0"
  s.files         = Dir["CONTRIBUTING.md", "LICENSE.md", "MAINTAINERS",
                        "README.md", "lib/**/*", "docs/**/*"]
  s.required_ruby_version = ">= 1.9.3"

  s.add_runtime_dependency "rake"
end
