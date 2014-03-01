# encoding: utf-8
#! /usr/bin/ruby

class Notifier

  def initialize(app_name, app_title)
    @app_name  = app_name
    @app_title = app_title
  end

  def show_message!(message)
    terminal_notifier_command(message)
  end
  
  private
  
  def terminal_notifier_command(message)
    cmd = "terminal-notifier -title '#{@app_title}' -message '#{message}' -sender 'com.google.Chrome' -group '#{@app_name}'"
    system(cmd)
  end
end
