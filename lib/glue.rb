# encoding: utf-8
#! /usr/bin/ruby

require 'bundler'
require File.expand_path('../jira_wrapper.rb',  __FILE__)
require File.expand_path('../clipboard.rb',  __FILE__)
require File.expand_path('../browser.rb',  __FILE__)

class Glue
  def initialize(config)
    @jira    = JIRA::Wrapper.new(config)
    @browser = Browser.new(:Chrome, @jira.base_url)
  end

  def issues_from_active_browser
    if key = @browser.jira_key_from_active_tab
      issue_on_clipboard(key)
    elsif jql = @browser.jira_search_from_active_tab
      issues_on_clipboard(@jira.issues_from_jql(jql))
    elsif filter = @browser.jira_filter_from_active_tab
      issues_on_clipboard(@jira.issues_from_filter(filter))
    else
      print "\a"; print "\a"
      puts "No issue found from active browser"
    end
  end
  
  def issues_on_clipboard(issues)
    html = '<br /><ul>'
    text = ''
    
    issues.each do |i|
      summary, link = @jira.issue_description_and_link_from_issue(i)
      html << "<li><a href='#{link}'>#{i.key}</a>: #{summary}</li>"
      text << "#{i.key}: #{summary} \n"
    end
    
    html << '</ul><br />'

    Clipboard.insert!(html, text)
    
    puts "Added #{issues.count} issues to clipboard"
    print "\a"
  end
  
  def issue_on_clipboard(key)
    puts "Searching for #{key}..."
    summary, link = @jira.issue_description_and_link(key)
    
    html = "<a href='#{link}'>#{key}</a>: #{summary}"
    text = "#{key}: #{summary}"
    
    Clipboard.insert!(html, text)
    
    puts "Added '#{text}' to clipboard"
    print "\a"
  end
end
