#!/usr/bin/ruby

# Script File: day.rb
# Author: Cameron Carroll; Created July 2013
# Purpose: Main file for day.rb time tracking app.

require 'rubygems'
require 'bundler/setup'

require 'yaml'
require 'fileutils'

require_relative 'lib/baseconfig'
require_relative 'lib/config'
require_relative 'lib/history'
require_relative 'lib/list'
require_relative 'lib/task'
require_relative 'lib/parser'

VERSION = '1.4'
CONFIG_FILE = ENV['HOME'] + '/.app_data/.daytodo'
HISTORY_FILE = ENV['HOME'] + '/.app_data/.daytodo_history'

#-------------- Monkey Classes:

class String
  def nan?
    self !~ /^\s*[+-]?((\d+_?)*\d+(\.(\d+_?)*\d+)?|\.(\d+_?)*\d+)(\s*|([eE][+-]?(\d+_?)*\d+)\s*)$/
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
    config.save_task(opts[:new_task], valid_days, opts[:time], nil, [])
  elsif opts[:clear]
    puts 'Clearing fulfillment data.'
    list.clear_fulfillments(config)
  elsif opts[:delete]
    task = list.find_task_by_number(opts[:chosen_context])
    if task
      if list.current_context == opts[:chosen_context]
        raise ArgumentError, "Selected task is the chosen context! Check out first!"
      else
        config.delete_task(task.name)
      end
      
    else
      raise ArgumentError, "Task not found! Selection out of bounds."
    end
    
  else
    raise ArgumentError, "No behavior defined! Check options parsing. "
  end
end

main()



