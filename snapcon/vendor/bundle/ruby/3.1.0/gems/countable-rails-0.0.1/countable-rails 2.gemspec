# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'countable/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "countable-rails"
  spec.version       = Countable::Rails::VERSION
  spec.authors       = ["Kyle Szives"]
  spec.email         = ["kjszives@gmail.com"]
  spec.summary          = "Countable is a script to allow for live paragraph-, word- and character- counting on an HTML element."
  spec.description      = "Countable is a script to allow for live paragraph-, word- and character- counting on an HTML element based on http://radlikewhoa.github.io/Countable."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", ">= 3.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end