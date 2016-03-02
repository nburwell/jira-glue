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
  base_url: https://ringrevenue.atlassian.net
  username: development
  # password must be stored in one of the following places:
  #  * ENV variable (use JIRA_PASSWORD)
  #  * keychain (create an entry matching the app_name above)

fields:
  impact: false
  
# optional (to use Safari)
# browser:
#   name: Safari
```

 * An example JIRA Base URL would look like: https://your-company.atlassian.net    
 * *If you typically log in via Google to JIRA*, you will need to create a password for your username in JIRA (Go to Profile within JIRA and set / change your password)
 * By default the script assumes Google Chrome (see above for how to specify a different browser in config file)
 
##### If using Keychain for password:
Create an entry in the **Keychain Access** app

 * Keychain Item Name: 'jira-glue' (must mach app[name] in config.yml)
 * Account Name: &lt;jira username&gt; (must match what is in config.yml)
 * Password: &lt;jira password&gt;

**Note:** On first run of the app, you will get a prompt that "security" is requesting access to the 'jira-glue' entry. Click "always allow" to not be prompted for this every time you use the app (especially useful if setup as a daemon process or triggered via hot key, etc).

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

* If you run into authentication errors, ensure you can log into JIRA via the web, using the username in the config file, and the password in your keychain or ENV var.

#### Optional Setup
If you want to have a single process running that stores the credentials and does the heavy-lifting for JIRA access, you can set up a launchd controlled process that acts as the server, and there is a preconfigured "browser-glue.rb" that can act as the client and be attached to a keyboard shortcut via Automator.

##### Install server as a launchd process
1. Copy sample plist file into LaunchAgents directory (edit path to rbenv and script)

  ```
  cp sample-local.jira-glue.plist ~/Library/LaunchAgents/local.jira-glue.plist
  ```

2. Register the daemon (this should start it now, and on every computer restart)

  ```
  launchctl load ~/Library/LaunchAgents/local.jira-glue.plist 
  ```

##### Test out server and client
 * Navigate in Chrome to a JIRA issue, filter, or search
 * In terminal from the main directory of the repo:

    ```
    ruby browser-glue.rb
    ```

* Success is having the client print out a response, and the JIRA key and description will be on your clipboard
* Failure modes: 
  * If credentials are wrong, you will see a notification
  * If browser tab does not contain a JIRA issue or filter, you will see a notification
  * If jira-glue server is not running correctly, you will not get a response from the ruby client script

##### Debug

* Tail the error and standard output from the launchd process to confirm it's running and with no errors:

```
tail -F /tmp/jira-glue.*
```

* If it's not running, make sure the launchd steps were followed correctly. Also check the "Console" app for errors regarding `jira-glue`


##### Launch client from Hotkey

* Use Automator (recommended), or Alfred with power pack or QuickSilver

###### Using Automator
* Launch "Automator"
* Create new "Service"
* Ensure that service receives 'no input' in 'any appliction'
* For action, select "Run Shell Script"
* Enter command to run script via rbenv, e.g.: `/Users/<username>/.rbenv/shims/ruby /Users/<username>/software/jira-glue/browser-glue.rb`
* Save action with a descriptive name
* Go to "Automator" menu, then "Services" > "Services Preferences"
* Find the new action and click to add a shortcut key (I use CTRL-J for JIRA)

###### Using Alfred, Quicksilver, etc
* Follow application-specific instructions to run a custom script based on a keyboard shortcut
* Run the file `browser-glue.rb` ensuring that correct Ruby version and Gems are picked up
  * E.g. `/Users/<username>/.rbenv/shims/ruby /Users/<username>/software/jira-glue/browser-glue.rb`
* Tip: if using Terminal, you may want to go to "Preferences" > Settings > Default profile > Shell and select "Close if the shell exited cleanly" under "When shell exits"

### Documentation

#### Direct access to JIRA Glue
```
require 'bundler'
require 'yaml'
require "lib/jira_glue.rb"

# load config
config = YAML.load_file("config.yml")
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
config = YAML.load_file("config.yml")

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

