# encoding: utf-8
#! /usr/bin/ruby

require 'bundler'
require 'net/https'
require 'jira-ruby'

module JIRA
  class Wrapper

    CUSTOMER_IMPACT_FIELD = "customfield_10100"
    
    JIRA_CLIENT_OPTIONS = {
        :context_path    => "",
        :use_ssl         => true
    }

    attr_reader :base_url
    
    def initialize(config, notifier, debug: false)
      client_options            = JIRA_CLIENT_OPTIONS.dup
            
      config && config["app"] && config["jira_client"]                                                  or raise "config file is not setup correctly: missing the 'app' and/or 'jira_client' key. See README for setup instructions"
      @app_name                 = config["app"]["name"]                                                 or raise "app['name'] not set in config"
      @base_url                 = config["jira_client"]["base_url"]                                     or raise "jira_client['base_url'] not set in config"
      @notifier                 = notifier

      client_options[:site]     = @base_url
      
      if config["jira_client"]["auth_type"] == "basic"
        client_options[:auth_type] = :basic
        client_options[:username] = config["jira_client"]["username"]                                     or raise "jira_client['username'] not set in config"
        client_options[:password] = self.class.get_password(@app_name, config["jira_client"]["username"]) or raise "jira_client['password'] not found / not accessible in keychain"
        
        @jira_client = JIRA::Client.new(client_options)
      else
        client_options[:signature_method] = 'RSA-SHA1'
        client_options[:consumer_key] = config["jira_client"]["consumer_key"]
        
        @jira_client = JIRA::Client.new(client_options)
        
        access_token = config["jira_client"]["access_token"] or raise "jira_client['access_token'] not set in config, and not using basic auth"
        access_key   = config["jira_client"]["access_key"]   or raise "jira_client['access_key'] not set in config, and not using basic auth"
        
        @jira_client.set_access_token(access_token, access_key)
        
        if debug
          puts "Consumer: #{client_options[:consumer_key]}"
          puts "Token: #{access_token}"
          puts "Key: #{access_key}"
          @jira_client.consumer.http.set_debug_output($stderr)
        end
      end
    end
    
    def find_issue(key)
      begin  
        issue = @jira_client.Issue.find(key)
      rescue JIRA::HTTPError => ex
        handle_jira_error(ex)
        raise ex
      end
    end
    
    def issues_from_jql(jql)
      begin
        @jira_client.Issue.jql(jql, { max_results: 100})
      rescue JIRA::HTTPError => ex
        handle_jira_error(ex, "Unable to get issues from jql: #{jql}")
        raise ex
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
        raise ex
      end
    end
    
    def issue_description_and_link_from_issue(issue)
      summary = issue.fields['summary']
      link    = "#{base_url}/browse/#{issue.key}"

      [summary, link, issue.fields[CUSTOMER_IMPACT_FIELD]]
    end
    
    def self.get_password(app_name, username)
      response = ENV["JIRA_PASSWORD"] || `security find-generic-password -w -l '#{app_name}' -a #{username}`.to_s.strip
      response.to_s.empty? ? nil : response
    end

    private
    
    def handle_jira_error(ex, context = nil)
      if ex.message == "Unauthorized"
        @notifier.show_message!("Unauthorized: please check that jira_username and jira_password are correctly set")
      else
        @notifier.show_message!("#{"#{context}\n" if context}#{ex.message}")
      end
    end
    
    ###########################
    
    public
    
    class Sprint

      TEAMS = {
        "Early Birds" => /early.?birds/i,
        "Hurricane" => /hurricane/i,
      }
  
      attr_accessor :jira_client, :id, :name

      def initialize(jira_client, id, name)
        @jira_client = jira_client
        self.id = id
        self.name = name
      end

      def issues
        @jira_client.Issue.jql("sprint = #{id}")
      end

      def burndown_remaining
        issues.map { |i| estimate_to_days((i.timeoriginalestimate || 0) - (i.timespent || 0)) }.inject(:+)
      end

      def self.all_active(client)
        sprints = JSON.parse(client.get('/rest/greenhopper/latest/sprintquery/1').body)['sprints']
        sprints.select { |sprint| sprint['state'] == 'ACTIVE' }
      end

      def self.team_sprints(client)
        TEAMS.map { |team_name, team_regex|
          team_sprint = Sprint.all_active(client).detect { |sprint| sprint['name'] =~ team_regex }
          Sprint.new(client, team_sprint['id'], team_sprint['name'])
        }
      end

      private

      def estimate_to_days(estimate)
        estimate ? estimate / (60.0 * 60 * 8) : 0
      end

    end
    
  end
end

