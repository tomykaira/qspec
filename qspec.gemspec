# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qspec/version'

Gem::Specification.new do |gem|
  gem.name          = "qspec"
  gem.version       = Qspec::VERSION
  gem.authors       = ["tomykaira"]
  gem.email         = ["tomykaira@gmail.com"]
  gem.description   = %q{QSpec inserts spec files to a queue.  Workers process that queue one by one.}
  gem.summary       = %q{QSpec is extension of RSpec.  Q is for queue, and quick.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.post_install_message = "Run qspec-helper init to create your config file"

  gem.add_dependency 'rspec-core', '~>2.13.1'
end
