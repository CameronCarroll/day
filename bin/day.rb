#!/usr/bin/env ruby

# DayRB Main File
# Day.rb is a minimalistic command-line to-do and time-tracking application.
# Created in July 2013, last updated September 2024
# See 'day.rb help' for usage.
#
# MIT License; See LICENSE file; Cam Carroll 2024

require_relative '../lib/day/configuration'
require_relative '../lib/day/tasklist'
require_relative '../lib/day/parser'
require_relative '../lib/day/presenter'

require 'fileutils'

VERSION = '2.0.6'

#-------------- User Configuration:
#-------------- Please DO edit the following to your liking:

# Configuration File: Stores tasks and their data
CONFIG_DIR = ENV['HOME'] + '/.config/'
CONFIG_FILE = CONFIG_DIR + 'dayrb_config_file'

# Colorization:
# Use ANSI color codes...
# (See http://bluesock.org/~willg/dev/ansi.html for codes.)
# (Change values back to 0 for no colorization.)
COMPLETION_COLOR = 0 # -- Used for completion printouts
CONTEXT_SWITCH_COLOR = 0 # -- Used to declare `Enter/Exit Context'
STAR_COLOR = 0 # -- Used for the description indicator star
TITLE_COLOR = 0 # -- Used for any titles
TEXT_COLOR = 0 # -- Used for basically everything that doesn't fit under the others.
INDEX_COLOR = 0 # -- Used for the index key which refers to tasks.
TASK_COLOR = 0 # -- Used for task name in printouts.

# Editor constant. Change to your preferred editor for adding descriptions.
EDITOR = 'vim'

#--------------

#[CUT HERE] Used in build script. Please don't remove.
# Note as of September 2024 - I don't remember what the build script was even supposed to do? Or where it is?
# ?? I published the new version to Rubygems and it seemed to work, so I have no idea.

#-------------- Monkey-Patch Definitions:

class String
  def nan?
    self !~ /^\s*[+-]?((\d+_?)*\d+(\.(\d+_?)*\d+)?|\.(\d+_?)*\d+)(\s*|([eE][+-]?(\d+_?)*\d+)\s*)$/
  end

  def number?
    !self.nan?
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

  def color_text
    colorize(TEXT_COLOR)
  end

  def color_index
    colorize(INDEX_COLOR)
  end

  def color_task
    colorize(TASK_COLOR)
  end
end

#-------------- Application Logic:
FileUtils.mkdir_p(CONFIG_DIR) unless Dir.exist? CONFIG_DIR

config = Configuration.new(CONFIG_FILE)
opts = Parser.parse_options(config)

# TODO: Simplify following logic, we don't need so many variables.
# Build task objects and separate into two lists, valid today and all tasks.
tasklist_object = Tasklist.new(config)
all_tasks = tasklist_object.all_tasks
valid_tasks = tasklist_object.valid_tasks

# Include either all days ("-a" flag) or just valid daily tasks:
if opts[:all]
  tasklist = all_tasks
else
  tasklist = valid_tasks
end

# Easier (named) access to config and opts:
new_context = opts[:task]
current_context = config.context
# If we were already tracking a task when program was called,
# this refers to the time spent in that task:
old_time = Time.now - config.entry_time if config.entry_time

# Take action based on operation:
case opts[:operation]
when :print
  Presenter.print_list(tasklist, current_context, old_time)
when :print_info
  Presenter.print_info(tasklist, new_context)
when :print_help
  Presenter.print_help
when :print_version
  Presenter.print_version
when :new
  Presenter.announce_new_task(new_context)
  config.new_task(opts)
when :switch
  Presenter.announce_switch(new_context, current_context, old_time)
  config.switch_to(new_context)
when :clear
  confirmation = Presenter.confirm_clear(new_context)
  config.clear_fulfillment(new_context) if confirmation
when :leave
  Presenter.announce_leave_context(current_context, old_time)
  config.clear_context
when :delete
  confirmation = Presenter.confirm_deletion(new_context, config.tasks[new_context]['description'])
  if confirmation
    config.delete(new_context)
  end
else
  Presenter.print_error_unknown
end

config.save(CONFIG_FILE)
