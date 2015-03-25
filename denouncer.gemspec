# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'denouncer/version'

Gem::Specification.new do |spec|
  spec.name          = "denouncer"
  spec.version       = Denouncer::VERSION
  spec.authors       = ["Julian Weber"]
  spec.email         = ["jweber@anynines.com"]
  spec.summary       = %q{Denouncer allows you to send notifications (SMTP, AMQP) with error/exception details using a simple interface. Denouncer is usable for all ruby applications, Rails is not required.}
  spec.description   = %q{Denouncer allows you to send notifications with error/exception details using a simple interface. New methods of sending error messages can be implemented using a pre-defined class interface. SMTP and AMQP  notification are the first implemented adapters. Denouncer is usable for all ruby applications, Rails is not required. Use denouncer to get informed on error occurences instantly.}
  spec.homepage      = "http://github.com/julweber/denouncer"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 1.9.0'

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
