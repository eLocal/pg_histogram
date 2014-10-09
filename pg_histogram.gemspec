# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pg_histogram/version'

Gem::Specification.new do |spec|
  spec.name          = "pg_histogram"
  spec.version       = PgHistogram::VERSION
  spec.authors       = ["David Roberts"]
  spec.email         = ["david.roberts@elocal.com"]
  spec.description   = %q{Creates a Histogram fron an ActiveRecord query}
  spec.summary       = %q{Histograms using PostgreSQL and ActiveRecord}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"
  spec.add_dependency "pg"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
