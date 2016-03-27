#!/usr/bin/env ruby

require 'bundler'
require 'yaml'
require File.expand_path('../lib/glue.rb',  __FILE__)

print "Loading JIRA configuration..."
config = YAML.load(ERB.new(File.read(File.expand_path('../config.yml',  __FILE__))).result)
puts " [Done]"


class NotifierStub
  def show_message!(message)
    puts message
  end
end

@jira  = JIRA::Wrapper.new(config, NotifierStub.new, debug: false)
key = "WEB-2000"

puts "Searching for #{key}..."
issue = @jira.find_issue(key)

if issue
  puts "We found issue with a description of: \"#{issue.summary}\""
  puts ""
else
  puts "Sorry, could not find issue from key: #{key}"
end