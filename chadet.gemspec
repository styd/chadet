# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chadet/version'

Gem::Specification.new do |spec|
  spec.name          = "chadet"
  spec.version       = Chadet::VERSION
  spec.date          = "2015-08-20"

  spec.authors       = ["Adrian Setyadi"]
  spec.email         = ["a.styd@yahoo.com"]
  spec.summary       = %q{Characters Detective: A command line game of guessing random characters intelligently.}
  spec.description   = %q{Characters Detective: A command line game of guessing random characters intelligently. Computer will generate a random set of characters. The default number of characters is 4 and the default set of characters is decimal digits from  0 to 9. After each guess you make, computer will tell you how many characters you guessed correctly and how many characters that their position you guessed correctly. Next, you can guess intelligently based on the previous answers.}
  spec.homepage      = "https://github.com/styd/chadet"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end