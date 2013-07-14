#!/usr/bin/ruby

# Script File: day.rb
# Author: Cameron Carroll; Created July 2013
# Purpose: Main file for day.rb time tracking app.

require 'rubygems'
require 'bundler/setup'

require 'trollop'
require 'pry'

VERSION = '0.1.1'

def parse_options
	opts = Trollop::options do
		version "day.rb #{VERSION} (c) 2013 Cameron Carroll"
		banner <<-EOS

day.rb is a time-tracking/to-do application. Tasks can either be defined
through the --new option, or manually by editing ~/.TODO
Simply select a task to begin timing it, and run the same command again to stop.

Usage:

  day.rb [options] [task number]

  Examples:
  # day.rb 1 (Toggle timing on task #1)
  # day.rb --new (Start new task wizard)
  # day.rb --new --name=MyTask (Add a new everyday task)
  # day.rb --new --name=MyTask --days m w (Add a new task for mondays and wednesdays)

  # day.rb 1 (Start timing task #1)
  # day.rb 1 (Stop timing task #1)

  # day.rb 1 (Start timing task #1)
  # day.rb 2 (Start timing task #2; Stop timing task #1)
  
EOS
		opt :new, "Add a new task."
		opt :name, "Name for new task.", :type => :string
		opt :days, "Days to enable task", :type => :strings
	end

	Trollop::die :days, "Must select --new flag to specify days" if opts[:days] && !opts[:new]

	return opts

end

def main
	opts = parse_options
end

main()