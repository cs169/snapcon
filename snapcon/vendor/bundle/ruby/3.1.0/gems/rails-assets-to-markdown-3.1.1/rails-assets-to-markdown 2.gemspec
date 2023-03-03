# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-to-markdown/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-to-markdown"
  spec.version       = RailsAssetsToMarkdown::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "An HTML to Markdown converter written in JavaScript"
  spec.summary       = "An HTML to Markdown converter written in JavaScript"
  spec.homepage      = "https://github.com/domchristie/to-markdown"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
