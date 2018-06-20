
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rate_limit/htb/version"

Gem::Specification.new do |spec|
  spec.name          = "rate_limit-htb"
  spec.version       = RateLimit::Htb::VERSION
  spec.authors       = ["Dominic Althaus"]
  spec.email         = ["althaus.dominic@gmail.com"]

  spec.summary       = %q{A ruby implementation of the hierarchical token bucket algorithm.}
  spec.description   = %q{A ruby implementation of the hierarchical token bucket algorithm. It allows you to define rates on different levels of a hierachie to limit the speed of certain operations.}
  spec.homepage      = "https://github.com/HappyKadaver/rate_limit-htb"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
