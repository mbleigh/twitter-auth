# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{twitter-auth}
  s.version = "0.1.21"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh"]
  s.date = %q{2009-04-27}
  s.description = %q{TwitterAuth is a Rails plugin gem that provides Single Sign-On capabilities for Rails applications via Twitter. Both OAuth and HTTP Basic are supported.}
  s.email = %q{michael@intridea.com}
  s.extra_rdoc_files = ["README.markdown"]
  s.files = ["CHANGELOG.markdown", "Rakefile", "README.markdown", "VERSION.yml", "generators/twitter_auth", "generators/twitter_auth/templates", "generators/twitter_auth/templates/migration.rb", "generators/twitter_auth/templates/twitter_auth.yml", "generators/twitter_auth/templates/user.rb", "generators/twitter_auth/twitter_auth_generator.rb", "generators/twitter_auth/USAGE", "lib/twitter_auth", "lib/twitter_auth/controller_extensions.rb", "lib/twitter_auth/cryptify.rb", "lib/twitter_auth/dispatcher", "lib/twitter_auth/dispatcher/basic.rb", "lib/twitter_auth/dispatcher/oauth.rb", "lib/twitter_auth/dispatcher/shared.rb", "lib/twitter_auth.rb", "spec/controllers", "spec/controllers/controller_extensions_spec.rb", "spec/controllers/sessions_controller_spec.rb", "spec/fixtures", "spec/fixtures/config", "spec/fixtures/config/twitter_auth.yml", "spec/fixtures/factories.rb", "spec/fixtures/fakeweb.rb", "spec/fixtures/twitter.rb", "spec/models", "spec/models/twitter_auth", "spec/models/twitter_auth/basic_user_spec.rb", "spec/models/twitter_auth/generic_user_spec.rb", "spec/models/twitter_auth/oauth_user_spec.rb", "spec/schema.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/twitter_auth", "spec/twitter_auth/cryptify_spec.rb", "spec/twitter_auth/dispatcher", "spec/twitter_auth/dispatcher/basic_spec.rb", "spec/twitter_auth/dispatcher/oauth_spec.rb", "spec/twitter_auth/dispatcher/shared_spec.rb", "spec/twitter_auth_spec.rb", "config/routes.rb", "app/controllers", "app/controllers/sessions_controller.rb", "app/models", "app/models/twitter_auth", "app/models/twitter_auth/basic_user.rb", "app/models/twitter_auth/generic_user.rb", "app/models/twitter_auth/oauth_user.rb", "app/views", "app/views/sessions", "app/views/sessions/_login_form.html.erb", "app/views/sessions/new.html.erb", "rails/init.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/mbleigh/twitter-auth}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{twitter-auth}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TwitterAuth is a Rails plugin gem that provides Single Sign-On capabilities for Rails applications via Twitter.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<oauth>, [">= 0.3.1"])
      s.add_runtime_dependency(%q<ezcrypto>, [">= 0.7.2"])
    else
      s.add_dependency(%q<oauth>, [">= 0.3.1"])
      s.add_dependency(%q<ezcrypto>, [">= 0.7.2"])
    end
  else
    s.add_dependency(%q<oauth>, [">= 0.3.1"])
    s.add_dependency(%q<ezcrypto>, [">= 0.7.2"])
  end
end
