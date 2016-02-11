$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'pincushion/version'

Gem::Specification.new do |s|
  s.name        = 'pincushion'
  s.version     = Pincushion::VERSION
  s.summary     = 'Predicate-centric classification toolkit'
  s.authors     = ['Ben Miller']
  s.email       = 'bmiller@rackspace.com'
  s.homepage    = 'https://github.com/bjmllr/pincushion'
  s.license     = 'MIT'
  s.files       = Dir['{spec,lib}/**/*.{rb,yaml}']
  s.test_files  = Dir['spec/**/*.{rb,yaml}']

  s.required_ruby_version = '~>2.0'

  s.add_development_dependency "bundler", "~> 1.0"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "minitest", "~> 5.0"
end
