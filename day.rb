#!/usr/bin/ruby

# Script File: day.rb
# Author: Cameron Carroll; Created July 2013
# Purpose: Main file for day.rb time tracking app.

require 'yaml'
require 'fileutils'

require_relative 'lib/baseconfig'
require_relative 'lib/config'
require_relative 'lib/history'
require_relative 'lib/list'
require_relative 'lib/task'
require_relative 'lib/parser'

VERSION = '1.6'

#-------------- User Configuration:
#-------------- Please DO edit the following to your liking:

CONFIG_FILE = ENV['HOME'] + '/.daytodo'
HISTORY_FILE = ENV['HOME'] + '/.daytodo_history'
# Colorization: 
# Use ANSI color codes...
# (See http://bluesock.org/~willg/dev/ansi.html for codes.)
# (Change values back to 0 for no colorization.)
COMPLETION_COLOR = 0 # -- Used for completion printouts
CONTEXT_SWITCH_COLOR = 0 # -- Used to declare `Enter/Exit Context'
STAR_COLOR = 0 # -- Used for the description indicator star
TITLE_COLOR = 0 # -- Used for any titles

#-------------- Monkey Classes:

class String
  def nan?
    self !~ /^\s*[+-]?((\d+_?)*\d+(\.(\d+_?)*\d+)?|\.(\d+_?)*\d+)(\s*|([eE][+-]?(\d+_?)*\d+)\s*)$/
  end

  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def color_completion
    colorize(COMPLETION_COLOR)
  end

  def color_context_switch
    colorize(CONTEXT_SWITCH_COLOR)
  end

  def color_star
    colorize(STAR_COLOR)
  end

  def color_title
    colorize(TITLE_COLOR)
  end
end

#-------------- Main control method:

def main

  opts = Parser.parse_options

  if opts[:chosen_context] && !opts[:delete]
    histclass = History.new(HISTORY_FILE)
    history_data = histclass.load
  end 

  config = Configuration.new(CONFIG_FILE)
  config_data = config.data

  # Generate list from configuration data:
  list = List.new(config_data[:tasks], config_data[:current_context], config_data[:context_entrance_time]);

  # Handle behaviors:
  if opts[:print]
    list.printout
  elsif opts[:chosen_context] && !opts[:delete]
    list.switch(config, histclass, opts[:chosen_context])
  elsif opts[:new_task]
    raise ArgumentError, "Duplicate task." if config_data[:tasks].keys.include? opts[:new_task]
    if opts[:valid_days]
      valid_days = Parser.parse_day_keys(opts)
    else
      valid_days = nil
    end
    config.save_task(opts[:new_task], valid_days, opts[:description], opts[:time], nil, [])
  elsif opts[:clear]
    puts 'Clearing fulfillment data.'
    list.clear_fulfillments(config)
  elsif opts[:delete]
    task = list.find_task_by_number(opts[:chosen_context])
    if task
      if list.current_context == opts[:chosen_context]
        raise ArgumentError, "Selected task is the chosen context! Are you sure you want to delete it? Check out first if so."
      else
        config.delete_task(task.name)
      end
    else
      raise ArgumentError, "Task not found! Selection out of bounds."
    end
  elsif opts[:info]
      task = list.find_task_by_number(opts[:info_context])
      if task.description
        list.print_description(task.name, task.description)
      else
        puts "(No description for #{task.name})"
      end
  else
    raise ArgumentError, "No behavior defined! Check options parsing. "
  end
end

main()



