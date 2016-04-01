# encoding: utf-8
#! /usr/bin/ruby

class Notifier

  def initialize(app_name, app_title, notification_app_name)
    @app_name  = app_name
    @app_title = app_title
    @notification_app_name = notification_app_name
  end

  def show_message!(message)
    terminal_notifier_command(message)
  end

  private

  def sender
    # TODO: Make the discovery of the name of notification app smarter.
    if @notification_app_name == "Safari"
      'com.apple.Safari'
    else
      'com.google.Chrome'
    end
  end

  def terminal_notifier_command(message)
    cmd = "terminal-notifier -title '#{@app_title}' -message '#{message}' -sender #{sender} -group '#{@app_name}' > /dev/null"
    system(cmd)
  end
end
