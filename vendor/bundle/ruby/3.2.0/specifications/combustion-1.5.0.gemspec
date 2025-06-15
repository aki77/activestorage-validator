# -*- encoding: utf-8 -*-
# stub: combustion 1.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "combustion".freeze
  s.version = "1.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Pat Allan".freeze]
  s.bindir = "exe".freeze
  s.date = "2024-07-07"
  s.description = "Test your Rails Engines without needing a full Rails app".freeze
  s.email = ["pat@freelancing-gods.com".freeze]
  s.executables = ["combust".freeze]
  s.files = ["exe/combust".freeze]
  s.homepage = "https://github.com/pat/combustion".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Elegant Rails Engine Testing".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 3.0.0"])
  s.add_runtime_dependency(%q<railties>.freeze, [">= 3.0.0"])
  s.add_runtime_dependency(%q<thor>.freeze, [">= 0.14.6"])
  s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.3"])
  s.add_development_dependency(%q<mysql2>.freeze, [">= 0"])
  s.add_development_dependency(%q<pg>.freeze, [">= 0"])
  s.add_development_dependency(%q<rails>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.81.0"])
  s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
end
