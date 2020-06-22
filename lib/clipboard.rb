# encoding: utf-8
#! /usr/bin/ruby

require 'rubygems'

begin
  require 'pasteboard'
rescue LoadError
  # this gem is not supported on Mac OS X 10.15+"
end


# Example usage
# -------------
# Clipboard.insert!('<a href="/jira">WEB-600</a>: IE bug somewhere probably',
#                   'WEB-600: IE bug somewhere probably')

class Clipboard
  def self.insert!(html, plain_text, slack_text)
    gem_uninitialized_wrapper("insert!") do
      pasteboard = Pasteboard.new

      item = [
        [Pasteboard::Type::HTML,                   html],
        [Pasteboard::Type::TEXT_MULTIMEDIA_DATA,   slack_text],
        [Pasteboard::Type::PLAIN_TEXT_TRADITIONAL, plain_text]
      ]

      pasteboard.put item
    end
  end

  def self.insert_text!(text)
    gem_uninitialized_wrapper("insert_text!") do
      pasteboard = Pasteboard.new
      pasteboard.put [[Pasteboard::Type::PLAIN_TEXT_TRADITIONAL, text]]
    end
  end

  def self.gem_uninitialized_wrapper method_name, &blk
    begin
      yield
    rescue NameError => ex
      if ex.message =~ /uninitialized constant/
        message = <<~EOS
          Pasteboard gem was not loaded. This gem is not supported on Mac OS X 10.15+ and so Clipboard::#{method_name} is not available.
          On earlier OS X versions, be sure to 'gem install pasteboard' and try again.
        EOS
        raise message
      else
        raise ex
      end
    end
  end
end
