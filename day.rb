#!/usr/bin/ruby

# Script File: day.rb
# Author: Cameron Carroll; Created July 2013
# Purpose: Main file for day.rb time tracking app.

require 'rubygems'
require 'bundler/setup'

require 'trollop'
require 'pry'

VERSION = '0.2'
CONFIG_FILE = ENV['HOME'] + '/.TODO'
HISTORY_FILE = ENV['HOME'] + '/.TODO_HISTORY'

def parse_options
	opts = Trollop::options do
		version "day.rb #{VERSION} (c) 2013 Cameron Carroll"
		banner <<-EOS

day.rb is a time-tracking/to-do app. It allows tasks to be defined for certain days, or everyday.
Simply select a task to begin timing it, and run the same command again to stop.
day.rb is intended to help keep you organized, and allow quick and unobtrusive context switching.

Usage:

  day.rb [options] [task number]

  Note: Days of the week can either be defined as individual letters, digraphs,
        where necessary, or trigraphs where desired.
  You could also use the internal representation, where 0 corresponds to sunday and 6 to saturday.

  Note: When using day.rb <noun>, integer numerical input will switch context,
        while alphanumeric input will create a new task.

  Examples:

  # day.rb -- List tasks for the day.
  # day.rb new_task -- Adds a new task; Defaults to 'every day.'
  # day.rb 0 -- Switch context & start timing new_task... tasks are indexed from 0.
  # day.rb new_task2
  # day.rb 1 -- Switch context and save time spent in previous context.
  # day.rb 1 -- Exit context, save times.

EOS
		opt :new, "Add a new task."
		opt :name, "Name for new task.", :type => :string
		opt :days, "Days to enable task", :type => :strings
	end

	Trollop::die :days, "Must select --new flag to specify days" if opts[:days] && !opts[:new]
  Trollop::die :name, "Must select --new flag to specify name" if opts[:name] && !opts[:new]
  Trollop::die :name, "Must specify a --name for the task" if opts[:days] && !opts[:name]

	return opts
end


class DayList
  attr_accessor :config_data, :history_data, :config_path, :history_path, :current_context  ,
                :context_entrance_time

  def initialize(config_filename, config_history_filename)
    @config_path = config_filename
    @history_path = config_history_filename
    generate_configuration unless File.exists? @config_path
    generate_history unless File.exists? @history_path
    @config_data = load_configuration
    @current_context = @config_data[:current_context]
    @context_entrance_time = @config_data[:context_entrance_time]
    @history_data = load_history
  end

  def generate_configuration
    puts "[NOTICE] Couldn't find config file (~/.TODO) -- Generating a new one."
    stub_config = {
      :version => VERSION,
      :tasks => []
    }
    save_yaml_data(stub_config, @config_path)
  end

  def generate_history
    puts "[NOTICE] Couldn't find history file (~/.TODO_HISTORY) -- Generating a new one."
    stub_history = {
      :VERSION => VERSION,
      :task_history => {}
    }
    save_yaml_data(stub_history, @history_path)
  end

  def load_history
    load_yaml_data(@history_path)
  end

  def save_history
    save_yaml_data(@history_data, @history_path)
  end

  def load_configuration
    load_yaml_data(@config_path)
  end

  def save_configuration
    @config_data[:current_context] = @current_context
    @config_data[:context_entrance_time] = @context_entrance_time
    save_yaml_data(@config_data, @config_path)
  end

  def load_yaml_data(filename)
    config_data = File.open(filename, 'r') { |handle| load = YAML.load(handle) }
    return config_data
  end

  def save_yaml_data(data, filename)
    File.new(filename, "w") unless File.exist? filename
    File.open(filename, "w") do |yaml_file|
      yaml_file.write(data.to_yaml)
    end
  end

  def print
    puts ""
    puts "Day:"
    counter = 0
    @config_data[:tasks].each do |task|
      puts counter.to_s + ': ' + task[:name]
      counter = counter + 1
    end
    puts ""
    puts "Current Context: " + find_task_name(@current_context) if @current_context
    puts ""
  end

  def create_task(name, days)
    puts "Adding new task: #{name}" 
    @config_data[:tasks] << { :name => name, :days => days}
    self.save_configuration
  end

  def find_task_name(numeric_selection)
    if @config_data[:tasks][numeric_selection.to_i]
      return @config_data[:tasks][numeric_selection.to_i][:name]
    else
      return nil
    end
  end

  def enter_context(numeric_selection)
    leave_context if @current_context
    @current_context = numeric_selection
    @context_entrance_time = Time.now.getutc
    self.save_configuration
  end

  def leave_context
    task_name = find_task_name(@current_context)
    @history_data[:task_history][task_name] = Array.new unless @history_data[:task_history][task_name]
    @history_data[:task_history][task_name] << [@context_entrance_time, Time.now.getutc]
    @current_context, @context_entrance_time = nil, nil
    save_history
    save_configuration
  end 

end

def main
  puts ""
	opts = parse_options
  list = DayList.new(CONFIG_FILE, HISTORY_FILE)
  if !opts[:new] && ARGV.empty?
    list.print
  elsif opts[:new] && !opts[:name] && !opts[:days]
    # call new task wizard
  elsif opts[:new] && opts[:name] && !opts[:days]
    list.create_task(opts[:name], nil)
  elsif opts[:new] && opts[:name] && opts[:days]
    list.create_task(opts[:name], opts[:days])
  else
    if ARGV.first.numeric?
      if ARGV.first == list.current_context
        puts "Leave context: " + list.find_task_name(ARGV.first)
        list.leave_context
      else
        if list.config_data[:tasks].size-1 >= ARGV.first.to_i
          puts "Enter context: " + list.find_task_name(ARGV.first)
          list.enter_context(ARGV.first)
        else
          puts "Invalid selection..."
          list.print
        end
      end
      
    else
      list.create_task(ARGV.first, nil)
    end
  end
end

class String
  def numeric?
       !!(self =~ /^[-+]?[0-9]+$/)
    end
end

main()