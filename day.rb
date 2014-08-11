#!/usr/bin/ruby

# DayRB Main File
# Day.rb is a minimalistic command-line to-do and time-tracking application.
# Created in July 2013
# See 'day.rb help' for usage.
#
# MIT License; See LICENSE file; Cameron Carroll 2014

require_relative 'lib/configuration'
require_relative 'lib/tasklist'
require_relative 'lib/parser'
require_relative 'lib/presenter'

VERSION = '2.0.0'

#-------------- User Configuration:
#-------------- Please DO edit the following to your liking:

# Configuration File: Stores tasks and their data
#CONFIG_FILE = ENV['HOME'] + '/.config/dayrb/daytodo'
CONFIG_FILE = ENV['HOME'] + '/code/day/tmp/config'

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

db = YAML::DBM.new(CONFIG_FILE)
config = Configuration.new(db)
opts = Parser.parse_options(config)

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
current_context = config.data['context']
old_time = Time.now - config.data['entry_time'] if config.data['entry_time']

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
  Presenter.announce_clear(new_context)
  config.clear_fulfillment(new_context)
when :leave
  Presenter.announce_leave_context(current_context, old_time)
  config.clear_context
when :delete
  Presenter.announce_deletion(new_context, config.data['tasks'][new_context]['description'])
  config.delete(new_context)
else
  Presenter.print_error_unknown
end

config.save
db.close