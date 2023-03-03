# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-markdown/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-markdown"
  spec.version       = RailsAssetsMarkdown::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = ""
  spec.summary       = ""
  spec.homepage      = "https://github.com/evilstreak/markdown-js"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]


    spec.post_install_message = "This component doesn't define main assets in bower.json.\nPlease open new pull request in component's repository:\nhttps://github.com/evilstreak/markdown-js"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
