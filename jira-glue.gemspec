$LOAD_PATH.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "jira-glue"
  spec.version       = "1.0.0"
  spec.authors       = ["Nick Burwell"]
  spec.email         = ["nick@invoca.com"]
  spec.summary       = %q{JIRA library.}
  spec.description   = %q{JIRA library.}
  spec.homepage      = "https://github.com/nburwell/jira-glue"

  spec.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "pasteboard"
  spec.add_dependency 'jira-ruby', '0.1.17'
  spec.add_dependency 'rb-appscript'
  spec.add_dependency 'terminal-notifier', '1.5.1'
end
