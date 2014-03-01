#!/usr/bin/env ruby

require 'bundler'
require 'yaml'
require File.expand_path('../lib/glue.rb',  __FILE__)

# load config
config = YAML.load_file(File.expand_path('../config.yml',  __FILE__))

g = Glue.new(config)
g.issues_from_active_browser