# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-sonos"
  s.version     = "1.0"
  s.authors     = ["noahsaso"]
  s.email       = ["noahsaso@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A plugin for SiriProxy to control 1 or multiple Sonos systems}
  s.description = %q{Sonos SiriProxy plugin.}

  s.rubyforge_project = "siriproxy-sonos"

  s.files         = `git ls-files 2> /dev/null`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/* 2> /dev/null`.split("\n")
  s.executables   = `git ls-files -- bin/* 2> /dev/null`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "httparty"
end
