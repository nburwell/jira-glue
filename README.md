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
irb> require './glue.rb'
=> true
```

Now you can construct and use the Glue object

```
g = Glue.new
```

### Documentation

#### Glue#issue_on_clipboard(jira_key)

* Takes a JIRA issue ID (project key followed by number, e.g. WEB-120)
* Sets HTML and text strings onto clipboard containing JIRA issue summary and link to issue
  * E.g. "[WEB-120](http://www.example.com/issues/WEB-120): An example bug title"
* Returns nil
```
g = Glue.new
g.issue_on_clipboard("STORY-200")
```
