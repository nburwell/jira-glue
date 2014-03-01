# encoding: utf-8
#! /usr/bin/ruby

require 'bundler'
require 'net/https'
require 'jira'

module JIRA
  class Wrapper

    JIRA_CLIENT_OPTIONS = {
        :context_path    => "",
        :auth_type       => :basic,
        :use_ssl         => true
    }

    attr_reader :base_url
    
    def initialize(config)
      client_options            = JIRA_CLIENT_OPTIONS.dup
            
      @app_name                 = config["app"]["name"]
      @base_url                 = config["jira_client"]["base_url"]                                     or raise "jira_client['base_url'] not set in config"

      client_options[:site]     = @base_url
      client_options[:username] = config["jira_client"]["username"]                                     or raise "jira_client['username'] not set in config"
      client_options[:password] = self.class.get_password(@app_name, config["jira_client"]["username"]) or raise "jira_client['password'] not found / not accessible in keychain"

      @jira_client = JIRA::Client.new(client_options)
    end
    
    def find_issue(key)
      begin  
        issue = @jira_client.Issue.find(key)
      rescue JIRA::HTTPError => ex
        handle_jira_error(ex)
        nil
      end
    end
    
    def issues_from_jql(jql)
      begin
        @jira_client.Issue.jql(jql)
      rescue JIRA::HTTPError => ex
        handle_jira_error(ex, "Unable to get issues from jql: #{jql}")
        nil
      end
    end
    
    def issues_from_filter(filter_id)
      begin
        filter = @jira_client.Filter.find(filter_id)
        
        if filter
          filter.issues
        else
          raise "Filter not found: #{filter_id}"
        end
      rescue JIRA::HTTPError => ex
        handle_jira_error(ex, "Unable to get issues from filter: #{filter_id}")
        nil
      end
    end
    
    def issue_description_and_link(key)
      if issue = find_issue(key)
        issue_description_and_link_from_issue(issue)
      else
        raise "Could not get issue from key: #{key}"
      end
    end
    
    def issue_description_and_link_from_issue(issue)
      summary = issue.fields['summary']
      link    = "#{base_url}/issues/#{issue.key}"

      [summary, link]
    end
    
    def self.get_password(app_name, username)
      `security 2>&1 >/dev/null find-generic-password -g -l '#{app_name}' -a #{username} \
       |ruby -e 'print $1 if STDIN.gets =~ /^password: "(.*)"$/'`
    end

    private
    
    def handle_jira_error(ex, context = nil)
      if ex.message == "Unauthorized"
        puts "Unauthorized: please check that jira_username and jira_password are correctly set"
      else
        puts context if context
        puts ex.message
      end
    end
  end
end
