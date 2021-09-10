JIRA Glue
=========

Command line utility app for JIRA tracking system.

Wraps the ruby JIRA API with the ability to:
* Get the issue(s) being viewed in the active browser tab and put on the clipboard in a nicely formatted way (convenient when wired to a global hotkey!)
* Using the command line interface:
  * Get a single issue from browser or user input
  * Get all issues from a filter ID
  * Get all issues from a JQL query
* With the provided classes, can easily build cool integrations or automated tasks around JIRA issues and their owners, statuses, etc

Has support for a simple client-server model so that the server can be set up once with JIRA credentials, then any local client script (such as a keyboard shortcut via Automator) can easily connect and get JIRA information.

In order to use any part of jira-glue or the handy jira-wrapper class, there is some one time setup needed. The client-server configuration is optional, with additional setup.

### One time setup

##### Create a file called `config.yml` in root of directory, with configuration details

```yaml
app:
  name: jira-glue
  title: JIRA glue

jira_client:
  base_url: https://your-company.atlassian.net
  # authentication params (see readme)

fields:
  impact: false

# optional (to use Safari)
# browser:
#   name: Safari
```

##### Get an API token

The recommened way to authenticate to the JIRA API is using an API token associated to your Jira user account. This works even if your Jira instance is configured for SSO via Google, Okta, etc. 

1) Log in with your account and go to Profile > Account Settings > Security > [Create and manage API tokens](https://id.atlassian.com/manage-profile/security/api-tokens) and create a new token.
1) Save the API token in the following ENV variable: `JIRA_PASSWORD` or if on MacOS, you can put into the Keychain app ([see details](https://github.com/nburwell/jira-glue/wiki/Authentication#if-using-keychain-for-password))
1) Provide the required key/values in the `config.yml` under `jira_client`:

```yaml
app:
  name: jira-glue
  title: JIRA glue

jira_client:
  base_url: https://your-company.atlassian.net
  auth_type: "basic"
  username: "your-jira-username"

fields:
  impact: false
```


[View other Authentication options, including user & password](https://github.com/nburwell/jira-glue/wiki/Authentication)

##### Setup Ruby and run bundle install (tested against Ruby 1.9.3, 2.1.2, and 2.4.2)

```bash
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

Optional [Alfred Workflow from this project](alfred/README.md) which requires the Alfred Powerpack

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
ruby ./browser.rb
# will run automatically and exit
```

##### Get descriptions & links from pasting input

* Searches for all issues and puts a bulleted list of linked issues (with their descriptions) on to the clipboard

```
ruby ./input.rb
# paste in JIRA keys, one line at a time
```

#### Build a Git Branch name from a Jira Issue
The file branch_name.rb can be used to create a git branch name from a Jira issue.

The name is created using the jira issue key followed by the
summary/description with most non-alphanumeric characters and spaces turned to underscores.


##### Example Branch Name:

Given the following:
* Jira Issue Number: STORY-123
* Jira Issue Description: Fix Jira-glue bug

The branch name would be the following:
```
STORY-123_fix_jira_glue_bug
```

##### Sample Output:
```
ruby ./branch_name.rb STORY-123
STORY-123_jira_issue_description
```

Use the -c flag after the jira issue to have the branch name copied to your clipboard.

```
ruby ./branch_name.rb STORY-123 -c
```

##### Adding a Prefix:
If you would like to add a prefix to the branch name, you may specify a date format in the config.yml file.

```
# config.yml
prefix:
    date_format: "your_date_format_here"
```

See the following article for information on date/time format strings:
https://ruby-doc.org/core-2.4.0/Time.html#method-i-strftime

##### Example with a prefix:
First set the date_format in config.yml
```
# config.yml
prefix:
    date_format: "%y%m"
```

Next run branch_name.rb
```
ruby ./branch_name.rb STORY-123 -c
```

The branch name would now have the following prefix:
```
YYMM/STORY-123_jira_issue_description
```

##### Sub-Task Support
If the JIRA Issue provided is a sub-task, the branch name will include the parent issue key and description followed by the sub-task key and description.

Given the following:
* Jira Issue Number: STORY-123
* Jira Issue Description: Fix Jira-glue bug
* Sub-Task of STORY-123 Issue Number: STORY-124
* Sub-Task of STORY-123 Issue Description: Add documentation

```
ruby ./branch_name.rb STORY-124
STORY-123_fix_jira_glue_bug.STORY-124_add_documentation
```
