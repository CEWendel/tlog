
Gem::Specification.new do |spec|

  spec.name         = "tlog"
  spec.version      = "0.0.7"
  spec.date         = "2013-05-27"

  spec.required_ruby_version = ">=1.9.3"

  spec.summary      = "CLI Project Time Logger"
  spec.description  = "tlog is a git-based command-line time logger that keeps track the time you've spend on different parts of a project"
  spec.license      = "GPL-2"

  spec.add_dependency("commander", "4.0")
  spec.add_dependency("chronic_duration", "0.10.2")
  spec.add_dependency("git", "1.2.5")
  spec.add_dependency("chronic", "0.9.1")
  spec.add_dependency("colorize", "0.5.8")

  spec.authors      = ["Chris Wendel"]
  spec.email        = "chriwend@umich.edu"
  spec.homepage     = "http://github.com/cewendel/tlog"

  spec.executables  = "tlog"

  spec.files        = `git ls-files`.split("\n")
  spec.require_path = "lib"

end
