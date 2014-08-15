# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-statsite"
  spec.version       = "0.0.4"
  spec.authors       = ["OKUNO Akihiro"]
  spec.email         = ["choplin.choplin@gmail.com"]
  spec.summary       = %q{Fluentd statsite plugin}
  spec.description   = %q{Fluentd plugin which caluculate statistics using statsite}
  spec.homepage      = "https://github.com/choplin/fluent-plugin-statsite"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
