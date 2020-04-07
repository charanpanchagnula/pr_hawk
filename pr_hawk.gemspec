# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pr_hawk/version'

Gem::Specification.new do |spec|
  spec.name = 'pr_hawk'
  spec.version = PrHawk::VERSION
  spec.authors = ['Charan Panchagnula']
  spec.email = ['charanftp3@cerner.com']
  spec.description = 'a web app that gives users visibility into how well GitHub repository owners are managing PRs.'
  spec.summary = ''
  spec.homepage = 'https://github.com/charanpanchagnula/pr_hawk'

  spec.files = Dir['lib/*.rb', 'README.md']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6'
end
