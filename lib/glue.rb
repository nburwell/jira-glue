# encoding: utf-8
#! /usr/bin/ruby

require 'bundler'
require File.expand_path('../notifier.rb',  __FILE__)
require File.expand_path('../jira_wrapper.rb',  __FILE__)
require File.expand_path('../clipboard.rb',  __FILE__)
require File.expand_path('../browser.rb',  __FILE__)

class Glue
  attr_reader :jira

  def initialize(config)
    browser_name = (config["browser"] && config["browser"]["name"]) || "Google Chrome" # Optional with backwards compatibility

    config && config["app"] or raise "config file is not setup correctly: it is missing the 'app' key. See README for setup instructions"

    @notifier      = Notifier.new(config["app"]["name"], config["app"]["title"], browser_name)
    @jira          = JIRA::Wrapper.new(config, @notifier)
    @browser       = Browser.new(browser_name, @jira.base_url)
    @prefix_format = config["prefix"] && config["prefix"]["date_format"]

    @impact = true # Backwards compatibility
    if fields = config["fields"]
      @impact = fields["impact"]
    end
  end

  def issues_from_active_browser
    begin
      issue = get_jira_key_from_active_browser
    rescue => ex
      # exceptions that the user should be alerted to were already handled
      # this is just to prevent the
      puts "#{ex.message} #{ex.backtrace}"
    end
    issue && issue_on_clipboard(issue)
  end

  def get_jira_key_from_active_browser
    if key = @browser.jira_key_from_active_tab
      @jira.find_issue(key)
    elsif jql = @browser.jira_search_from_active_tab
      @jira.issues_from_jql(jql)
    elsif filter = @browser.jira_filter_from_active_tab
      @jira.issues_from_filter(filter)
    else
      @notifier.show_message!("No issue found from active browser")
      false
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

    Clipboard.insert!(html, text, text)

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
    slack_text = "#{issue.key}: #{summary}\n#{link}"
    Clipboard.insert!(html, text, slack_text)

    # @notifier.show_message!("Added #{issue.key} to clipboard")
    [summary, link, impact]
  end

  def build_branch_name_from_issue(issue, copy_to_clipboard = true)
    issue || return

    summary        = formatted_summary(issue)
    parent_summary = parent_summary(issue)
    prefix         = @prefix_format ? "#{Time.new.strftime(@prefix_format)}/" : ''
    branch_name    = "#{prefix}#{parent_summary}#{summary}"

    Clipboard.insert_text!(branch_name) if copy_to_clipboard

    branch_name
  end

  def display_notification(message)
    @notifier.show_message!(message)
  end

  private

  def formatted_summary(issue)
    issue_description, = @jira.issue_description_and_link_from_issue(issue)

    # Formatting: downcase -> replace specific non-alphanumeric characters with spaces -> remove non-alphanumberic characters -> replace spaces with join
    formatted_issue_description = issue_description.downcase.tr(':;()-.', ' ').gsub(/[^a-z0-9\s&]/, '').split(' ').join('_')

    "#{issue.key}_#{formatted_issue_description}"
  end

  def parent_summary(issue)
    if issue.issuetype.name == 'Sub-task'
      parent_issue = @jira.find_issue(issue.parent['key'])
      "#{formatted_summary(parent_issue)}."
    else
      ''
    end
  end
end

