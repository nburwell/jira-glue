# encoding: utf-8
#! /usr/bin/ruby

require 'rubygems'
require 'appscript'

include Appscript

# Example usage
# -------------
# b = Browser.new(:Chrome)
# b.jira_key_from_active_tab

class Browser
  def initialize(type, base_url)
    case type
    when :Chrome
      "Google Chrome"
    else
      raise "Unsupported browser type: #{type}"
    end
    
    @browser  = app("Google Chrome")
    @base_url = base_url
  end
    
  def jira_key_from_active_tab()
    if matches = get_url.match(/#{@base_url.sub(/https?:\/\//, '')}\/browse\/([^?]*)/)
      matches[1]
    end
  end
  
  def jira_search_from_active_tab()
    if matches = get_url.match(/#{@base_url.sub(/https?:\/\//, '')}\/issues\/\?jql=([^=]*)/)
      CGI::unescape(matches[1])
    end
  end
  
  def jira_filter_from_active_tab()
    if matches = get_url.match(/#{@base_url.sub(/https?:\/\//, '')}\/issues\/\?filter=([^=]*)/)
      matches[1]
    end
  end
  
  def get_url()
    if @browser && @browser.windows.first
      # windows.first is the front (active) window
      @browser.windows.first.active_tab.URL.get
    end
  end
end