# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "munin/version"

Gem::Specification.new do |s|
  s.name        = "munin-plugin"
  s.version     = Munin::VERSION
  s.authors     = ["Alban Peignier"]
  s.email       = ["alban@tryphon.eu"]
  s.homepage    = "http://github.com/albanpeignier/munin/"
  s.summary     = %q{Create munin plugins in ruby}
  s.description = %q{The munin gem provides a base class to create munin plugins in ruby}

  s.rubyforge_project = "munin-plugin"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
