#!/usr/bin/ruby

# Script File: day.rb
# Author: Cameron Carroll; Created July 2013
# Purpose: Main file for day.rb time tracking app.

require 'rubygems'
require 'bundler/setup'

require 'trollop'
require 'yaml'
require 'fileutils'

VERSION = '0.3'
CONFIG_FILE = ENV['HOME'] + '/.app_data/.daytodo'
HISTORY_FILE = ENV['HOME'] + '/.app_data/.daytodo_history'

def parse_options
	opts = Trollop::options do
		version "day.rb #{VERSION} (c) 2013 Cameron Carroll"
		banner <<-EOS

day.rb is a time-tracking/to-do app. It allows tasks to be defined for certain days, or everyday.
It is intended to help keep you organized, and allow quick and unobtrusive context switching.


Usage:

  Simply select a task to begin timing it, and run the same command again to stop.

  day.rb [options] [task number]

  Examples:

  # day.rb -- List tasks for the day.
  # day.rb new_task -- Adds a new task; Defaults to 'every day.'
  # day.rb 0 -- Switch context & start timing new_task... tasks are indexed from 0.
  # day.rb new_task2
  # day.rb 1 -- Switch context and save time spent in previous context.
  # day.rb 1 -- Exit context, save times.

  #day.rb new_task3 m w thu -- Create new_task3 for monday, wednesday and thursday.

  Notes:

  # Days of the week can either be defined as individual letters and digraphs,
    where necessary, or trigraphs where desired. Must be given as a list of lowercase keys.
    ie: m, tu, w, th, f, sa, su
    You could also use the internal representation, where 0 corresponds to sunday and 6 to saturday.

  # When using day.rb <noun>, integer numerical input will switch context,
    while alphanumeric input will create a new task.

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
                :context_entrance_time, :valid_tasks

  def initialize(config_filename, config_history_filename)
    @config_path = config_filename
    @history_path = config_history_filename
    FileUtils.mkdir_p(File.dirname(@config_path))
    generate_configuration unless File.exists? @config_path
    generate_history unless File.exists? @history_path
    @config_data = load_configuration
    @valid_tasks = load_valid_tasks
    @current_context = @config_data[:current_context]
    @context_entrance_time = @config_data[:context_entrance_time]
    @history_data = load_history
  end

  def generate_history
    puts "[NOTICE] Couldn't find history file (~/.TODO_HISTORY) -- Generating a new one."
    stub_history = {
      :VERSION => VERSION,
      :task_history => {}
    }
    save_yaml_data(stub_history, @history_path)
  end

  def generate_configuration
    puts "[NOTICE] Couldn't find config file (~/.TODO) -- Generating a new one."
    stub_config = {
      :version => VERSION,
      :tasks => []
    }
    save_yaml_data(stub_config, @config_path)
  end

  def load_valid_tasks
    valid_tasks = []
    unless @config_data[:tasks].empty?
      @config_data[:tasks].each do |task|
        valid_tasks << task if valid_task? task
      end
    end

    return valid_tasks
  end

  def valid_task?(task)
    if task[:days]
      today = Time.new.wday #0 is sunday, 6 saturday

      weekday_short = case today
        when 0 then 'su'
        when 1 then 'm'
        when 2 then 'tu'
        when 3 then 'w'
        when 4 then 'th'
        when 5 then 'f'
        when 6 then 'sa'
      end

      weekday_long = case today
        when 0 then 'sun'
        when 1 then 'mon'
        when 2 then 'tue'
        when 3 then 'wed'
        when 4 then 'thu'
        when 5 then 'fri'
        when 6 then 'sat'
      end

      if task[:days].include?(today) || task[:days].include?(weekday_short)
        return true
      elsif task[:days].include? weekday_long || task[:days].empty?
        return true
      else
        return false
      end 
    else
      return true
    end
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
    config_data = {} unless config_data
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
    @valid_tasks.each do |task|
      puts counter.to_s + ': ' + task[:name]
      counter = counter + 1
    end
    puts ""
    if @current_context
      puts "Current Context: " + find_task_name(@current_context)
      print_context_time
    end
    puts ""
  end

  def print_context_time
    time = "%0.2f" % ((Time.new.getutc - @context_entrance_time) / 60)
    puts "Time spent in context: " + time.to_s + " minutes."
  end

  def create_task(name, days)
    puts "Adding new task: #{name}" 
    @config_data[:tasks] << { :name => name, :days => days}
    self.save_configuration
  end

  def find_task_name(numeric_selection)
    if @valid_tasks[numeric_selection.to_i]
      return @valid_tasks[numeric_selection.to_i][:name]
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
    print_context_time
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