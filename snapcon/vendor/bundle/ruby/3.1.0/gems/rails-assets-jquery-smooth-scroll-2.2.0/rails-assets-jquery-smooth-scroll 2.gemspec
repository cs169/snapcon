# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-jquery-smooth-scroll/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-jquery-smooth-scroll"
  spec.version       = RailsAssetsJquerySmoothScroll::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "Easy implementation of smooth scrolling for same-page links"
  spec.summary       = "Easy implementation of smooth scrolling for same-page links"
  spec.homepage      = "https://github.com/kswedberg/jquery-smooth-scroll"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-jquery", ">= 1.7.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
