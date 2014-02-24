#!/usr/bin/env ruby

# load ENV vars
load File.expand_path('../secrets',  __FILE__)

require 'bundler'
require File.expand_path('../lib/glue.rb',  __FILE__)

g = Glue.new
g.issue_from_active_browser