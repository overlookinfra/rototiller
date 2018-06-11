test_name 'install rototiller' do
  sut = find_only_one('agent')

  gem_name = ''
  step 'build rototiller' do
    built_gem_info = `gem build rototiller.gemspec`
    # fun
    # get the gemname from the output of gem build
    #   find the row with /File/, de-array, split on space, de-array again
    # previous attempts of just looking at the filesystem and infering the latest gem can break easily
    gem_name = built_gem_info.split("\n").select { |a| a =~ /File/}.first.split.last
  end
  teardown do
    `rm #{gem_name}`
  end
  scp_to(sut, gem_name, gem_name)

  if ENV['RAKE_VER']
    rake_version = Gem::Version.new(ENV['RAKE_VER']).approximate_recommendation
    on(sut, "gem install rake --force --version '#{rake_version}'")
  else
    on(sut, "gem install rake --force")
  end

  on(sut, "gem install ./#{gem_name}")
end
