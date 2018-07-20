# encoding: utf-8
#! /usr/bin/ruby

require 'rubygems'
require 'pasteboard'


# Example usage
# -------------
# Clipboard.insert!('<a href="/jira">WEB-600</a>: IE bug somewhere probably',
#                   'WEB-600: IE bug somewhere probably')

class Clipboard
  def self.insert!(html, plain_text, slack_text)
    pasteboard = Pasteboard.new

    item = [
      [Pasteboard::Type::HTML,                   html],
      [Pasteboard::Type::TEXT_MULTIMEDIA_DATA,   slack_text],
      [Pasteboard::Type::PLAIN_TEXT_TRADITIONAL, plain_text]
    ]

    pasteboard.put item
  end

  def self.insert_branch!(branch_name)
    pasteboard = Pasteboard.new

    name = [[Pasteboard::Type::PLAIN_TEXT_TRADITIONAL, branch_name]]

    pasteboard.put name
  end
end
