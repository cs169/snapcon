# -*- encoding: utf-8 -*-
# stub: omniauth-discourse 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "omniauth-discourse".freeze
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ioannis Tsagkatakis".freeze]
  s.date = "2023-03-01"
  s.description = "A generic strategy for OmniAuth to authenticate against Discourse forum's SSO.".freeze
  s.email = ["jtsagat@gmail.com".freeze]
  s.files = [".gitignore".freeze, ".rubocop.yml".freeze, "Gemfile".freeze, "LICENSE".freeze, "README.md".freeze, "Rakefile".freeze, "lib/omniauth-discourse.rb".freeze, "lib/omniauth-discourse/version.rb".freeze, "lib/omniauth/strategies/discourse.rb".freeze, "lib/omniauth/strategies/discourse/sso.rb".freeze, "omniauth-discourse.gemspec".freeze]
  s.homepage = "https://github.com/linuxuser-gr/omniauth-discourse".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.26".freeze
  s.summary = "A generic strategy for OmniAuth to authenticate against Discourse forum's SSO.".freeze

  s.installed_by_version = "3.3.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<omniauth>.freeze, ["~> 2.0"])
    s.add_runtime_dependency(%q<addressable>.freeze, ["~> 2.7"])
    s.add_runtime_dependency(%q<rack>.freeze, [">= 0"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.9"])
  else
    s.add_dependency(%q<omniauth>.freeze, ["~> 2.0"])
    s.add_dependency(%q<addressable>.freeze, ["~> 2.7"])
    s.add_dependency(%q<rack>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.9"])
  end
end
