# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "apache2nginx/version"

Gem::Specification.new do |s|
  s.name        = "apache2nginx"
  s.version     = Apache2nginx::VERSION
  s.authors     = ["Vladimir Támara Patiño"]
  s.email       = ["vtamara@pasosdeJesus.org"]
  s.homepage    = ""
  s.summary     = %q{Convierte archivo de configuracion de apache a nginx}
  s.description = %q{Reconoce algunas directivas}

  s.rubyforge_project = "apache2nginx"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "apacheconf-parser"
  s.add_runtime_dependency "treetop"
end
