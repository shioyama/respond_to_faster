
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "respond_to_faster/version"

Gem::Specification.new do |spec|
  spec.name          = "respond_to_faster"
  spec.version       = RespondToFaster::VERSION
  spec.authors       = ["Chris Salzberg"]
  spec.email         = ["chris@dejimata.com"]

  spec.summary       = %q{Faster response times for your ActiveRecord attribute methods.}
  spec.description   = %q{Patches ActiveRecord to make models returned from custom queries respond much faster.}

  spec.homepage      = 'https://github.com/shioyama/respond_to_faster'
  spec.license       = 'MIT'

  spec.files        = Dir['{lib/**/*,[A-Z]*}']
  spec.bindir        = "exe"
  spec.require_paths = ["lib"]

  spec.add_dependency 'activerecord', '>= 5.1', '< 6.0'
  spec.add_development_dependency "bundler", "~> 1.16.a"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
