# encoding: utf-8
#! /usr/bin/ruby

require 'bundler'
require './jira_wrapper.rb'
require './clipboard.rb'

class Glue
  def initialize()
    @jira = JIRA::Wrapper.new
  end

  def issue_on_clipboard(key)
    puts "Searching for #{key}..."
    summary, link = @jira.get_issue_description_and_link(key)
    
    html = "<a href='#{link}'>#{key}</a>: #{summary}"
    text = "#{key}: #{summary}"
    
    Clipboard.insert!(html, text)
    
    puts "Added '#{text}' to clipboard"
  end
end
