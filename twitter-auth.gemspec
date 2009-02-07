# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{twitter-auth}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh"]
  s.date = %q{2009-02-07}
  s.description = %q{TODO}
  s.email = %q{michael@intridea.com}
  s.files = ["README.markdown", "VERSION.yml", "generators/twitter_auth", "generators/twitter_auth/templates", "generators/twitter_auth/templates/migration.rb", "generators/twitter_auth/templates/user.rb", "generators/twitter_auth/twitter_auth_generator.rb", "lib/twitter_auth", "lib/twitter_auth/controller_extensions.rb", "lib/twitter_auth/cryptify.rb", "lib/twitter_auth.rb", "spec/spec_helper.rb", "spec/twitter_auth_spec.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/mbleigh/twitter-auth}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Standard authentication stack for Rails using Twitter to log in.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
