require_relative 'lib/network_profile/version'

Gem::Specification.new do |spec|
  spec.name          = "network_profile"
  spec.version       = NetworkProfile::VERSION
  spec.authors       = ["Stefan Wienert"]
  spec.email         = ["info@stefanwienert.de"]

  spec.summary       = %q{Extract profile metadata from various social-media-profiles}
  spec.description   = %q{Extract profile metadata from various social-media-profiles, such as Twitter, XING, Github, Stackoverflow or generic og-metatags.}
  spec.homepage      = "https://github.com/pludoni/network_profile"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/pludoni/network_profile"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "typhoeus"
  spec.add_dependency "rdf-microdata"
  spec.add_dependency "activesupport", ">= 5.0.0"
  spec.add_dependency "nokogiri"
  spec.add_dependency "rexml"
end
