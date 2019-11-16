require_relative "lib/osqp/version"

Gem::Specification.new do |spec|
  spec.name          = "osqp"
  spec.version       = OSQP::VERSION
  spec.summary       = "OSQP (Operator Splitting Quadratic Program) solver for Ruby"
  spec.homepage      = "https://github.com/ankane/osqp"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@chartkick.com"

  spec.files         = Dir["*.{md,txt}", "{lib,vendor}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.4"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", ">= 5"
  spec.add_development_dependency "numo-narray" unless ENV["APPVEYOR"]
end
