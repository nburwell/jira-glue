JIRA Glue
=========

Command line utility app for JIRA tracking system. 

Has support for a simple client-server model so that the server can be set up once with JIRA credentials, then any local client script (such as a keyboard shortcut via Automator) can easily connect and get JIRA information.

In order to use any part of jira-glue or the handy jira-wrapper class, there is some one time setup needed. The client-server configuration is optional, additional setup.

### One time setup

##### Create a file called `config.yml` in root of directory, with configuration details

```yaml
app:
  name: jira-glue
  title: JIRA glue

jira_client:     
  base_url: https://your-company.atlassian.net
  # authentication params

fields:
  impact: false
  
# optional (to use Safari)
# browser:
#   name: Safari
```

##### Get Oauth Credentials

To authenticate to the JIRA API via Oauth, you will need to get an access token and key from JIRA.  You will then store these locally in the config.yml file (alternatively you can use environment variables with ERB substitution, see below).

Oauth Token Generator for Invoca Instance: https://jira-glue.herokuapp.com/

1) Paste the provided key/values into the `config.yml`:

```yaml
app:
  name: jira-glue
  title: JIRA glue

jira_client:     
  # ---- PASTE OAUTH CREDENTIALS FROM GENERATOR HERE: ----
  base_url: https://your-company.atlassian.net
  consumer_key: '...'
  access_token: '...'
  access_key: '...'

fields:
  impact: false
```

2) Save private key that was used to generate the Application Link in JIRA to `rsakey.pem` in the root folder
  * (Can be found in LastPass under Jira Glue)


[View other Authentication options](https://github.com/nburwell/jira-glue/wiki/Authentication)

##### Setup Ruby and run bundle install (tested against Ruby 1.9.3 and 2.1.2)

```bash
rbenv local 2.1.2
gem install bundler -v 1.5.3  # tested against this version, likely newer versions also work
bundle install
rbenv rehash
```

##### Test it out!
```
ruby demo.rb
```

* If you run into authentication errors, try `ruby test.rb` for a simpler script with more debug output.

#### Optional Setup

Visit the [Launchd server client setup](https://github.com/nburwell/jira-glue/wiki/Launchd-server-client-setup) wiki page if you are interested in setting up a launchd process that makes global hotkey automation easy.

Set up [global hotkeys using Automator or other Mac solutions](https://github.com/nburwell/jira-glue/wiki/Setup-Global-Hotkeys-(Mac)) for quick access to JIRA ticket information on the clipboard.

### Documentation

#### Direct access to JIRA Glue
```
require 'bundler'
require 'yaml'
require "lib/jira_glue.rb"

# load config
config = YAML.load(ERB.new(File.read("config.yml")))
glue = Glue.new(config)
```

You can then do stuff like:
```
g.issues_from_active_browser
```

#### Direct access to JIRA Wrapper
To skip the glue interface and use the JIRA wrapper directly, you can do the following:

```
require 'bundler'
require 'yaml'
require "lib/jira_wrapper.rb"

# load config
config = YAML.load(ERB.new(File.read("config.yml")))

# set up a notifier interface, must define "show_message!"
class Notifier
  def show_message!(msg)
    puts "JIRA message: #{msg}"
  end
end

jira = JIRA::Wrapper.new(config, Notifier.new)
```

You can then have access to the following methods:
```
# key (string) such as "WEB-123" or "STORY-456"
jira.find_issue(key)       
  
# jql (string) JIRA query language syntax such as "issuekey in (WEB-123, STORY-456) order by issuekey"
jira.issues_from_jql(jql)  
  
# filter_id (string) JIRA filter ID, found in url when viewing a saved filter
jira.issues_from_filter(filter_id)

# issue (JIRA::Issue) 
jira.issue_description_and_link_from_issue(issue)
```

The Issue objects returned are `JIRA::Resource::Issue` instances from https://github.com/sumoheavy/jira-ruby/tree/v0.1.17  
See their documentation and source code for more information on what is available.

#### Client scripts
This assumes you have done the optional setup to get a server daemon running.

##### Get description(s) & link(s) from Browser

* Searches for the currently viewed issue and puts the issue (with description and link) on to the clipboard
* Supports viewing a filter or custom JQL too and will create a bulleted list of issues and their descriptions/links
* Looks for active tab in Chrome by default, can search Safari instead (in config.yml)

```
ruby ./browser-glue.rb
# will run automatically and exit
```

##### Get descriptions & links from pasting input

* Searches for all issues and puts a bulleted list of linked issues (with their descriptions) on to the clipboard

```
ruby ./input.rb
# paste in JIRA keys, one line at a time
```

