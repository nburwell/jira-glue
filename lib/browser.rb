# encoding: utf-8
#! /usr/bin/ruby

require 'rubygems'
require 'appscript'

include Appscript

# Example usage
# -------------
# b = Browser.new("Google Chrome")
# b.jira_key_from_active_tab

class Browser
  def initialize(name, base_url)
    ["Google Chrome", "Safari"].include?(name) or raise "Unsupported browser: #{name}"
    
    @browser  = app(name)
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

  def is_safari?
    @browser.name.get == "Safari"
  end
  
  def get_url()
    if @browser && @browser.windows.first
      # https://gist.github.com/vitorgalvao/5392178#file-get_title_and_url-applescript
      if is_safari?
        @browser.documents.first.URL.get
      else
        # windows.first is the front (active) window
        @browser.windows.first.active_tab.URL.get
      end
    end
  end
end