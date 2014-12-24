JIRA Glue
=========

Command line utility app for JIRA tracking system

### Setup

##### Create a file called `config.yml` in root of directory, with configuration details

```yaml
app:
  name: jira-glue
  title: JIRA glue

jira_client:     
  base_url: https://ringrevenue.atlassian.net
  username: development
  # password must be stored in keychain. Create an entry matching the app_name
  
# optional (to use Safari)
# browser:
#  name: Safari
```
   
 * An example JIRA Base URL would look like: https://your-company.atlassian.net    
 * If you typically log in via Google to JIRA, you will need to create a password for your username in JIRA (Go to Profile)
 * By default the script assumes Google Chrome (see above for how to specify a different browser in config file)
 
##### Create an entry in the **Keychain Access** app
 * Keychain Item Name: 'jira-glue' (must mach app[name] in config.yml)
 * Account Name: &lt;jira username&gt; (must match what is in config.yml)
 * Password: &lt;jira password&gt;

**Note:** On first run of the app, you will get a prompt that "security" is requesting access to the 'jira-glue' entry. Click "always allow" to not be prompted for this every time you use the app (especially useful if triggered via hot key).

##### Setup Ruby and run bundle install (tested against Ruby 1.9.3)

```bash
rbenv local 1.9.3-p448
gem install bundler -v 1.5.3
bundle install
rbenv rehash
```

##### Test out the script directly
 * Navigate in Chrome to a JIRA issue, filter, or search
 * In terminal from the main directory of the repo:

    ```
    ruby browser-glue.rb
    ```

### Launch from Hotkey

* Use Automator (recommended), or Alfred with power pack or QuickSilver

#### Using Automator
* Launch "Automator"
* Create new "Service"
* Ensure that service receives 'no input' in 'any appliction'
* For action, select "Run Shell Script"
* Enter command to run script via rbenv, e.g.: `/Users/<username>/.rbenv/shims/ruby /Users/<username>/software/jira-glue/browser-glue.rb`
* Save action with a descriptive name
* Go to "Automator" menu, then "Services" > "Services Preferences"
* Find the new action and click to add a shortcut key (I use CTRL-J for JIRA)

#### Using Alfred, Quicksilver, etc
* Follow application-specific instructions to run a custom script based on a keyboard shortcut
* Run the file `browser-glue.rb` ensuring that correct Ruby version and Gems are picked up
  * E.g. `/Users/<username>/.rbenv/shims/ruby /Users/<username>/software/jira-glue/browser-glue.rb`
* Tip: if using Terminal, you may want to go to "Preferences" > Settings > Default profile > Shell and select "Close if the shell exited cleanly" under "When shell exits"

### Documentation

#### Glue#issues_from_active_browser

* Searches for issue and calls issue_on_clipboard if active tab in Chrome is viewing a JIRA issue
* Returns nil
```
g = Glue.new(YAML.load_file('config.yml'))
g.issues_from_active_browser
```
