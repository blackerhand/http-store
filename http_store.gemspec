lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "http_store/version"

Gem::Specification.new do |spec|
  spec.name    = "http_store"
  spec.version = HttpStore::VERSION
  spec.authors = ["black"]
  spec.email   = ["black@paimingjia.com"]

  spec.summary     = %q{store the http request, it based on rest-client}
  spec.description = %q{This lib is based on rest-clint http client. It generate a table to store the http request info}
  spec.homepage    = "https://github.com/308820773/http-store"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/308820773/http-store"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client"
  spec.add_dependency "hashie"
  spec.add_dependency "activerecord"
  spec.add_dependency "rails"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "byebug"
end

