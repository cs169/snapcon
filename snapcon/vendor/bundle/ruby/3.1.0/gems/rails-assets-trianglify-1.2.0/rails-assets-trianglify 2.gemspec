# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-trianglify/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-trianglify"
  spec.version       = RailsAssetsTrianglify::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "Trianglify is a javascript library for generating colorful triangle meshes that can be used as SVG images and CSS backgrounds."
  spec.summary       = "Trianglify is a javascript library for generating colorful triangle meshes that can be used as SVG images and CSS backgrounds."
  spec.homepage      = "https://github.com/qrohlf/trianglify"
  spec.license       = "GPLv3"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
