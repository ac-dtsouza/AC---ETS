# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{multipart-post}
  s.version = "1.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nick Sieger"]
  s.date = %q{2012-02-13}
  s.description = %q{Use with Net::HTTP to do multipart form posts.  IO values that have #content_type, #original_filename, and #local_path will be posted as a binary file.}
  s.email = ["nick@nicksieger.com"]
  s.homepage = %q{https://github.com/nicksieger/multipart-post}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{caldersphere}
  s.rubygems_version = %q{1.7.2}
  s.summary = %q{A multipart form post accessory for Net::HTTP.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
