require_relative "lib/osqp/version"

Gem::Specification.new do |spec|
  spec.name          = "osqp"
  spec.version       = OSQP::VERSION
  spec.summary       = "OSQP (Operator Splitting Quadratic Program) solver for Ruby"
  spec.homepage      = "https://github.com/ankane/osqp-ruby"
  spec.license       = "Apache-2.0"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@ankane.org"

  spec.files         = Dir["*.{md,txt}", "{lib,vendor}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 3.1"

  spec.add_dependency "fiddle"
end
