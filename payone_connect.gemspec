require File.expand_path('../lib/payone_connect/version', __FILE__)

Gem::Specification.new do |s|
  s.name = %q{payone_connect}
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Patrick Huesler", "Alexander Lang", "Jan Raasch", "Christoph Hugo"]
  s.date = %q{2014-08-04}
  s.description = %q{Connects to the payone gateway and passes the parameters}
  s.email = %q{patrick.huesler@gmail.com}
  s.version       = PayoneConnect::VERSION
  s.homepage = %q{http://github.com/phuesler/payone_connect}
  s.require_paths = ["lib"]
  s.summary = %q{Simple http client for the psp payone api (http://www.payone.de/)}
  s.files         = `git ls-files`.split($\)
  s.test_files    = s.files.grep(%r{^spec/})

  s.add_dependency 'activesupport'
  s.add_development_dependency(%q<rspec>, ["~> 2.1"])
  s.add_development_dependency(%q<fakeweb>, [">= 0"])
  s.add_development_dependency(%q<rake>, ["< 11"])
end
