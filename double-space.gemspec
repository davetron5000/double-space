lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "double/space/version"

Gem::Specification.new do |spec|
  spec.name          = "double-space"
  spec.license       = "APACHE"
  spec.version       = Double::Space::VERSION
  spec.authors       = ["Dave Copeland"]
  spec.email         = ["davetron5000@gmail.com"]

  spec.summary       = %q{Manage a short story and create both human readable output and a manuscript suitable for submissions}
  spec.description   = %q{}


  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["source_code_uri"] = "https://github.com/davetron5000/double-space"
  spec.metadata["changelog_uri"] = "https://github.com/davetron5000/double-space/changes"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency('rdoc')
  spec.add_dependency('methadone', '~> 2.0.2')
  spec.add_development_dependency('rspec', '~> 3')
end
