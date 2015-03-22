# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'exceptionist/version'

Gem::Specification.new do |spec|
  spec.name          = "exceptionist"
  spec.version       = Exceptionist::VERSION
  spec.authors       = ["Julian Weber"]
  spec.email         = ["jweber@anynines.com"]
  spec.summary       = %q{Exceptionist allows you to send notifications (SMTP, AMQP) with error/exception details using a simple interface.}
  spec.description   = %q{Exceptionist allows you to send notifications with error/exception details using a simple interface. New methods of sending error messages can be implemented using a pre-defined class interface. SMTP and AMQP  notification are the first implemented adapters. Use exceptionist to get informed on error occurences instantly.}
  spec.homepage      = "http://github.com/julweber/exceptionist"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "bunny"
end
