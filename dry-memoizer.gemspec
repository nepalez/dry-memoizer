Gem::Specification.new do |gem|
  gem.name     = "dry-memoizer"
  gem.version  = "0.0.1"
  gem.author   = ["Vladimir Kochnev (marshall-lee)", "Andrew Kozin (nepalez)"]
  gem.email    = ["hashtable@yandex.ru", "andrew.kozin@gmail.com"]
  gem.homepage = "https://github.com/dryrb/dry-memoizer"
  gem.summary  = "DSL for memoization"
  gem.license  = "MIT"

  gem.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files       = gem.files.grep(/^spec/)
  gem.extra_rdoc_files = Dir["README.md", "LICENSE"]

  gem.required_ruby_version = ">= 2.2"

  gem.add_development_dependency "guard-rspec", "~> 4.0"
  gem.add_development_dependency "rake", "~> 10.5"
  gem.add_development_dependency "dry-initializer", "~> 0.0.1"
  gem.add_development_dependency "ice_nine", "~> 0.11.2"
end
