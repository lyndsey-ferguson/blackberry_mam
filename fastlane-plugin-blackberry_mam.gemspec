# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/blackberry_mam/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-blackberry_mam'
  spec.version       = Fastlane::BlackberryMam::VERSION
  spec.author        = 'Lyndsey Ferguson'
  spec.email         = 'ldf.public@outlook.com'

  spec.summary       = 'A fastlane plugin that works with Blackberry Dynamics (formerly Good Dynamics) provides Mobile Application Management'
  spec.homepage      = "https://github.com/lyndsey-ferguson/blackberry_mam"
  spec.license       = 'MIT'

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 2.28.3'
end
