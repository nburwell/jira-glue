# encoding: utf-8
#! /usr/bin/ruby

require 'bundler'
require File.expand_path('../notifier.rb',  __FILE__)
require File.expand_path('../jira_wrapper.rb',  __FILE__)
require File.expand_path('../clipboard.rb',  __FILE__)
require File.expand_path('../browser.rb',  __FILE__)

class Glue
  def initialize(config)
    @notifier = Notifier.new(config["app"]["name"], config["app"]["title"])
    @jira     = JIRA::Wrapper.new(config, @notifier)
    @browser  = Browser.new(:Chrome, @jira.base_url)
    @impact = true # Backwards compatibility
    if fields = config["fields"]
      @impact = fields["impact"]
    end
  end

  def issues_from_active_browser
    if key = @browser.jira_key_from_active_tab
      issue_on_clipboard(@jira.find_issue(key))
    elsif jql = @browser.jira_search_from_active_tab
      issues_on_clipboard(@jira.issues_from_jql(jql))
    elsif filter = @browser.jira_filter_from_active_tab
      issues_on_clipboard(@jira.issues_from_filter(filter))
    else
      @notifier.show_message!("No issue found from active browser")
    end
  end

  def issues_on_clipboard(issues)
    issues or return

    html = '<br /><ul>'
    text = ''

    issues.each do |i|
      summary, link = @jira.issue_description_and_link_from_issue(i)
      html << "<li><a href='#{link}'>#{i.key}</a>: #{summary}</li>"
      text << "#{i.key}: #{summary} \n"
    end

    html << '</ul><br />'

    Clipboard.insert!(html, text)

    # @notifier.show_message!("Added #{issues.count} issues to clipboard")
  end

  def issue_on_clipboard(issue)
    issue or return

    summary, link, impact = @jira.issue_description_and_link_from_issue(issue)

    impact_html = if @impact
                    inner_html = impact.blank? ? "<b>Not provided</b>" : impact
                    "<br /><br /><i>Customer Impact:</i><br />#{inner_html}<br />"
                  end

    html = "<a href='#{link}'>#{issue.key}</a>: #{summary}#{impact_html}"
    text = "#{issue.key}: #{summary}"

    Clipboard.insert!(html, text)

    # @notifier.show_message!("Added #{issue.key} to clipboard")
  end
end
