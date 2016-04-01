#!/usr/bin/env ruby

require 'bundler'
require 'yaml'
require File.expand_path('../lib/glue.rb',  __FILE__)

print "Loading JIRA configuration..."

# load config
config = YAML.load(ERB.new(File.read(File.expand_path('../config.yml',  __FILE__))).result)
g = Glue.new(config)

puts " [Done]"

print "Getting JIRA issue(s) from active browser tab..."

if g.issues_from_active_browser
  puts " [Done]"
  puts ""
  puts "Issues are now on your clipboard in HTML format, ready to be pasted into an email, etc!"
else
  puts " [Error]"
  puts "Most likely your active browser tab is not on a supported JIRA page."
end