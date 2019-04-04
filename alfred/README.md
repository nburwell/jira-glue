# Setup Alfred workflow
 * Link the shell script into your local bin directory.  This is where Alfred looks for the script by default
 ```sh
   ln -s $PWD/bin/jira-link-copy.sh ~/bin/
 ```
  * If you use `rbenv` uncomment that line in the .sh script
  * Install the Alfred Workflow
```sh
  open 'alfred/Jira Link Copy.alfredworkflow'
```
* If you used a different directory to hold the script you will need to update the workflow External Script Path

![Workflow](workflow.png "Workflow in alfred")

![Workflow Edit](workflow_edit_script.png)


