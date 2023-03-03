# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-waypoints/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-waypoints"
  spec.version       = RailsAssetsWaypoints::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "Easily execute a function when you scroll to an element."
  spec.summary       = "Easily execute a function when you scroll to an element."
  spec.homepage      = "https://github.com/imakewebthings/waypoints"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
