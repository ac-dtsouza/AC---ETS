# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ansi}
  s.version = "1.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Thomas Sawyer", "Florian Frank"]
  s.date = %q{2012-01-29}
  s.description = %q{The ANSI project is a superlative collection of ANSI escape code related libraries
enabling ANSI colorization and stylization of console output. Byte for byte
ANSI is the best ANSI code library available for the Ruby programming
language.}
  s.email = ["transfire@gmail.com"]
  s.extra_rdoc_files = ["HISTORY.rdoc", "README.rdoc", "QED.rdoc", "COPYING.rdoc"]
  s.files = ["HISTORY.rdoc", "README.rdoc", "QED.rdoc", "COPYING.rdoc"]
  s.homepage = %q{http://rubyworks.github.com/ansi}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.7.2}
  s.summary = %q{ANSI at your fingertips!}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<detroit>, [">= 0"])
      s.add_development_dependency(%q<qed>, [">= 0"])
      s.add_development_dependency(%q<lemon>, [">= 0"])
    else
      s.add_dependency(%q<detroit>, [">= 0"])
      s.add_dependency(%q<qed>, [">= 0"])
      s.add_dependency(%q<lemon>, [">= 0"])
    end
  else
    s.add_dependency(%q<detroit>, [">= 0"])
    s.add_dependency(%q<qed>, [">= 0"])
    s.add_dependency(%q<lemon>, [">= 0"])
  end
end
