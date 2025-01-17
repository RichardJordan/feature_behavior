# frozen_string_literal: true

require_relative "lib/feature_behavior/version"

Gem::Specification.new do |spec|
  spec.name = "feature_behavior"
  spec.version = FeatureBehavior::VERSION
  spec.authors = ["Richard Jordan"]
  spec.email = ["richarddjordan@gmail.com"]
  spec.licenses = ["MIT"]

  spec.summary = "Add behaviors to RSpec feature spec runs"
  spec.description = "Break up example blocks into behavior steps."
  spec.homepage = "https://github.com/RichardJordan/feature_behavior"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/RichardJordan/feature_behavior"
  spec.metadata["changelog_uri"] = "https://github.com/RichardJordan/feature_behavior/blob/main/CHANGELOG"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rspec", "~> 3.0"
end
