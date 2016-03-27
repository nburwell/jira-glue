#!/usr/bin/env ruby

require 'bundler'
require 'yaml'
require File.expand_path('../lib/glue.rb',  __FILE__)
require File.expand_path('../lib/comm/server.rb',  __FILE__)

print "Loading JIRA configuration..."

# load config
config = YAML.load(ERB.new(File.read(File.expand_path('../config.yml',  __FILE__))).result)
g = Glue.new(config)

puts " [Done]"

print "Setting up communication pipes..."
server = Comm::Server.new
puts " [Done]"

server.start do |message|
  case message.strip
  when /\Aget:browser/
    puts "Get from active browser tab"

    begin
      g.issues_from_active_browser
      server.send("HTML on clipboard")
    rescue => ex
      g.display_notification(ex.message)
      server.send("An error occurred: #{ex.message}")
    end

  when /\Aget:jql:/
    jql = message.strip.gsub(/\Aget:jql:/, '')
    puts "Get JIRA issues from jql: #{jql}"

    begin
      g.issues_on_clipboard(g.jira.issues_from_jql(jql))
      server.send("HTML on clipboard")
    rescue => ex
      server.send("An error occurred: #{ex.message}")
    end

  when /\Aget:key:/
    key = message.strip.gsub(/\Aget:key:/, '')
    puts "Get JIRA key: '#{key}'"

    begin
      issue = g.jira.find_issue(key)
      summary, link, impact = g.issue_on_clipboard(issue)

      server.send(summary)
    rescue => ex
      server.send("An error occurred: #{ex.message}")
    end

  else
    puts "Unknown message: '#{message}'"
  end
end
