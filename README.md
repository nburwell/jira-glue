JIRA Glue
=========

Command line utility app for JIRA tracking system

### Setup

The following environment vars are required:

```
export jira_username=<username>
export jira_password=<password>
export jira_base_url=<url>
```

An example base URL would look like:  
https://your-company.atlassian.net

Setup Ruby and run bundle install (tested against Ruby 1.9.3)

```
rbenv local 1.9.3-p44
bundle install
```

Launch `irb` and then require main file

```
$ irb
irb> require './lib/glue.rb'
=> true
```

Now you can construct and use the Glue object

```
g = Glue.new
```

### Launch from Hotkey

* Use Automator (recommended), or Alfred with power pack or QuickSilver
* Create a file called `secrets` next to browser-glue.rb

    ```
    ENV['jira_username'] = 'sample_user'
    ENV['jira_password'] = 'p@ss'
    ENV['jira_base_url'] = 'https://your-company.atlassian.net'
    ```

#### Using Automator
* Launch "Automator"
* Create new "Service"
* Ensure that service receives 'no input' in 'any appliction'
* For action, select "Run Shell Script"
* Enter command: `/Users/<username>/.rbenv/shims/ruby /Users/<username>/software/jira-glue/browser-glue.rb`
* Save action with a descriptive name
* Go to "Automator" menu, then "Services" > "Services Preferences"
* Find the new action and click to add a shortcut key (I use CTRL-J for JIRA)

#### Using Alfred, Quicksilver, etc
* Follow application-specific instructions to run a custom script based on a keyboard shortcut
* Run the file `browser-glue.rb` ensuring that correct Ruby version and Gems are picked up
  * E.g. `/Users/<username>/.rbenv/shims/ruby /Users/<username>/software/jira-glue/browser-glue.rb`
* Tip: if using Terminal, you may want to go to "Preferences" > Settings > Default profile > Shell and select "Close if the shell exited cleanly" under "When shell exits"

### Documentation

#### Glue#issue_from_active_browser

* Searches for issue and calls issue_on_clipboard if active tab in Chrome is viewing a JIRA issue
* Returns nil
```
g = Glue.new
g.issue_from_active_browser
```

#### Glue#issue_on_clipboard(jira_key)

* Takes a JIRA issue ID (project key followed by number, e.g. WEB-120)
* Sets HTML and text strings onto clipboard containing JIRA issue summary and link to issue
  * E.g. "[WEB-120](http://www.example.com/issues/WEB-120): An example bug title"
* Returns nil
```
g = Glue.new
g.issue_on_clipboard("STORY-200")
```
