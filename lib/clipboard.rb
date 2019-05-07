# encoding: utf-8
#! /usr/bin/ruby

require 'rubygems'
require 'clipboard'


# Example usage
# -------------
# Clipboard.insert!('<a href="/jira">WEB-600</a>: IE bug somewhere probably',
#                   'WEB-600: IE bug somewhere probably')

class ClipboardHelper
  def self.insert!(html, plain_text, slack_text)
    # Clipboard = Clipboard.new

    Clipboard.copy plain_text
  end

  def self.insert_text!(text)
    # Clipboard = Clipboard.new

    Clipboard.copy [[Clipboard::Type::PLAIN_TEXT_TRADITIONAL, text]]
  end
end
