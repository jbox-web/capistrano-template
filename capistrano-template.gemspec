# frozen_string_literal: true

require_relative 'lib/capistrano/template/version'

Gem::Specification.new do |s|
  s.name          = 'capistrano-template'
  s.version       = Capistrano::Template::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Dieter Späth']
  s.email         = ['d.spaeth@faber.de']
  s.homepage      = 'https://github.com/faber-lotto/capistrano-template'
  s.summary       = %q(Erb-Template rendering and upload for capistrano 3)
  s.description   = %q(A capistrano 3 plugin that aids in rendering erb templates and uploads the content to the server if the file does not exists at the remote host or the content did change)
  s.license       = 'MIT'

  s.required_ruby_version = '>= 3.0.0'

  s.files = `git ls-files`.split("\n")

  s.add_runtime_dependency 'capistrano', '~> 3.0'

  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov'
end
