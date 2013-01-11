Gem::Specification.new do |spec|

  spec.name        = "tlog"
  spec.version     = "0.0.1"
  spec.executables << 'tlog'
  spec.date        = "2012-12-26"

  spec.summary     = "CLI Time Project Logger"
  spec.description = "CLI Time Project Logger"
  spec.license     = "GPL-2"

  spec.add_dependency("commander", "~> 4.0")

  spec.authors     = ["Chris Wendel"]
  spec.email       = "chriwend@umich.edu"

  spec.executables = "tlog"

  spec.files        = ["lib/tlog.rb"]

end
