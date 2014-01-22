# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kurchatov/version'

Gem::Specification.new do |spec|
  spec.name = 'kurchatov'
  spec.version = Kurchatov::VERSION
  spec.authors = ['Vasiliev Dmitry']
  spec.email = ['vadv.mkn@gmail.com']
  spec.summary = %q{Gem for monitoring with riemann.}
  spec.description = %q{Gem for monitoring with riemann.}
  spec.homepage = 'https://github.com/vadv/kurchatov'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'beefcake', '>= 0.3.5'
  spec.add_dependency 'ohai', '>= 6.20.0'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'ruby-prof'
end
