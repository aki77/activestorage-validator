
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "activestorage/validator/version"

Gem::Specification.new do |spec|
  spec.name          = "activestorage-validator"
  spec.version       = ActiveStorage::Validator::VERSION
  spec.authors       = ["aki"]
  spec.email         = ["aki77@users.noreply.github.com"]

  spec.summary       = %q{ActiveStorage blob validator.}
  spec.description   = %q{ActiveStorage blob validator.}
  spec.homepage      = "https://github.com/aki77/activestorage-validator"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  spec.files         = Dir["{app,lib,rails}/**/*", "CODE_OF_CONDUCT.md", "LICENSE.txt", "Rakefile", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> 5.2.0"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
