require 'bundler'
require File.expand_path('../lib/comm/client.rb',  __FILE__)

client = Comm::Client.new

puts "Paste in issues (one per line) then hit ctrl-d"
issue_input = ARGF.read
issue_keys = issue_input.split("\n").map(&:strip).map { |i| i.empty? ? nil : i }.compact

jql = "issuekey in (#{issue_keys.join(',')}) order by issuekey"

puts "***"
puts "Search for keys: #{issue_keys.inspect}"
puts "Using jql: #{jql}"

client.send("get:jql:#{jql}")
