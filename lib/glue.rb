# encoding: utf-8
#! /usr/bin/ruby

require 'bundler'
require File.expand_path('../jira_wrapper.rb',  __FILE__)
require File.expand_path('../clipboard.rb',  __FILE__)
require File.expand_path('../browser.rb',  __FILE__)

class Glue
  def initialize()
    @jira    = JIRA::Wrapper.new
    @browser = Browser.new(:Chrome)
  end

  def issue_from_active_browser
    if key = @browser.jira_key_from_active_tab
      issue_on_clipboard(key)
    else
      print "\a"; print "\a"
      puts "No issue found from active browser"
    end
  end
  
  def issue_on_clipboard(key)
    puts "Searching for #{key}..."
    summary, link = @jira.get_issue_description_and_link(key)
    
    html = "<a href='#{link}'>#{key}</a>: #{summary}"
    text = "#{key}: #{summary}"
    
    Clipboard.insert!(html, text)
    
    puts "Added '#{text}' to clipboard"
    print "\a"
  end
end
