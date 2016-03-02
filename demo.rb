#!/usr/bin/env ruby

require 'bundler'
require 'yaml'
require File.expand_path('../lib/glue.rb',  __FILE__)

print "Loading JIRA configuration..."

config = YAML.load_file(File.expand_path('../config.yml',  __FILE__))
g = Glue.new(config)

puts " [Done]"

puts "Provide a JIRA key to look up and hit enter (e.g. WEB-123):"
key = gets.strip

puts "Searching..."
issue = g.jira.find_issue(key)

if issue
  puts "We found issue with a description of: \"#{issue.summary}\""
  g.issue_on_clipboard(issue)
  puts ""
  puts "Now the key and description are on your clipboard."
  puts "If you paste this in a rich text editor like Gmail, it will also have a link to the item!"
  puts "If you paste into a plain text area, it will just give you the key and summary"
  puts ""
else
  puts "Sorry, could not find issue from key: #{key}"
end