# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-bootstrap-select/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-bootstrap-select"
  spec.version       = RailsAssetsBootstrapSelect::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "The jQuery plugin that brings select elements into the 21st century with intuitive multiselection, searching, and much more."
  spec.summary       = "The jQuery plugin that brings select elements into the 21st century with intuitive multiselection, searching, and much more."
  spec.homepage      = "https://developer.snapappointments.com/bootstrap-select"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-jquery", ">= 1.9.1", "< 4"
  spec.add_dependency "rails-assets-bootstrap", ">= 3.0.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
