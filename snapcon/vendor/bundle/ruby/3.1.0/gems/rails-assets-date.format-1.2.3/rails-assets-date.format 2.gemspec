# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-date.format/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-date.format"
  spec.version       = RailsAssetsDateFormat::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "A date formatting library for JavaScript"
  spec.summary       = "A date formatting library for JavaScript"
  spec.homepage      = "https://github.com/tiger-seo/date.format"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
