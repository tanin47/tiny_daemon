require './lib/tiny_daemon/version'

Gem::Specification.new do |s|
  s.name = "tiny_daemon"
  s.version = TinyDaemon::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Tanin Na Nakorn"]
  s.email = ["tanin47@yahoo.com"]
  s.homepage = "http://github.com/tanin47/tiny_daemon"
  s.summary = %q{tiny_daemon}
  s.description = %q{Daemonize a Ruby code}

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {tests}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency("rake")
  s.add_development_dependency("minitest")
end