#!/usr/bin/env ruby

require 'bundler'
require 'yaml'
require File.expand_path('../lib/glue.rb', __FILE__)

config = YAML.load(ERB.new(File.read(File.expand_path('../config.yml', __FILE__))).result)
g = Glue.new(config)

input_array = ARGV

key = input_array.find{ |arg| arg != '-c' }

copy_to_clip_board = input_array.include? '-c'

begin
  issue = (key == '') ? g.get_jira_key_from_active_browser : g.jira.find_issue(key)
rescue JIRA::HTTPError => ex
  STDERR.puts "#{ex} #{ex.response}: #{ex.message}"
  # Exit 2 for bash script
  exit 2
end

if issue
  puts g.build_branch_name_from_issue(issue, copy_to_clip_board)
else
  exit 3
end

