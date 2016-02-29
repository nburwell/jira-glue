require 'bundler'
require File.expand_path('../lib/comm/client.rb',  __FILE__)

client = Comm::Client.new
client.send("get:browser")