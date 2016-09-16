# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'urlcheck/version'

Gem::Specification.new do |spec|
  spec.name          = "urlcheck"
  spec.version       = Urlcheck::VERSION
  spec.authors       = ["Mike Nicholaides"]
  spec.email         = ["mike.nicholaides@gmail.com"]

  spec.summary       = %q{Checks URLs to see if they are up.}
  spec.description   = %q{It's special because it can cache the results.}
  spec.homepage      = "https://www.promptworks.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "moneta", '~> 0.8.0'
  spec.add_dependency "typhoeus", '>= 0.7'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
