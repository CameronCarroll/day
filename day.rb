#!/usr/bin/ruby

# Script File: day.rb
# Author: Cameron Carroll; Created July 2013
# Purpose: Main file for day.rb time tracking app.

require 'rubygems'
require 'bundler/setup'

require 'trollop'
require 'yaml'
require 'fileutils'
require 'pry'

VERSION = '0.91'
CONFIG_FILE = ENV['HOME'] + '/.app_data/.daytodo'
HISTORY_FILE = ENV['HOME'] + '/.app_data/.daytodo_history'

#-------------- Monkey Classes:

class String
  def nan?
    self !~ /^\s*[+-]?((\d+_?)*\d+(\.(\d+_?)*\d+)?|\.(\d+_?)*\d+)(\s*|([eE][+-]?(\d+_?)*\d+)\s*)$/
  end
end

#-------------- App Classes:


class List

  attr_accessor :tasks, :current_context, :context_entrance_time

  def initialize(task_list, current_context, context_entrance_time)
    @tasks = []
    if task_list
      task_list.each do |task|
        #task.first refers to the key (task name), since the task is stored [key, val]
        task_instance = Task.new(task.first, task[1][:days], task[1][:commitment])
        @tasks << task_instance
      end
    end

    @current_context = current_context if current_context
    @context_entrance_time = context_entrance_time if context_entrance_time
  end

  def print
    puts "Day.rb (#{VERSION})"
    puts "Today's tasks:"
    puts ""
    ii = 0
    @tasks.each_with_index do |task, ii|
      puts ii.to_s + ': ' + task.name
    end
  end

  def switch(config, histclass, context_number)

    if @tasks.empty?
      raise RuntimeError, "No tasks are defined."
    end

    unless (0..@tasks.size-1).member?(context_number.to_i)
      raise ArgumentError, "Context choice out of bounds."
    end

    unless @current_context
      puts 'didnt find a context, switching to new one'
      config.save_context_switch(context_number)
    end

    if @current_context == context_number
      puts 'found a context to exit, but not switching to a new one.'
      current_task = find_task_by_number(@current_context)
      histclass.save_history(current_task.name, @context_entrance_time, Time.now.getutc)
      config.clear_current_context
      return
    end

    if @current_context && @context_entrance_time
      puts 'found a context, saving history and switching to new one.'
      current_task = find_task_by_number(@current_context)
      histclass.save_history(current_task.name, @context_entrance_time, Time.now.getutc)
      config.clear_current_context
      config.save_context_switch(context_number)
    end
  end

  def find_task_by_number(numeric_selection)
    if @tasks[numeric_selection.to_i]
      return @tasks[numeric_selection.to_i]
    else
      return nil
    end
  end
end

class Task

  attr_reader :name, :valid_days, :time_commitment

  def initialize(name, valid_days, time_commitment)
    @name = name
    @valid_days = valid_days
    @time_commitment = time_commitment
  end

  def self.valid_today?
    if @valid_days
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

      if @valid_days.include?(today) || @valid_days.include?(weekday_short)
        return true
      elsif @valid_days.include? weekday_long || @valid_days.empty?
        return true
      else
        return false
      end 
    else
      return true # valid everyday
    end
  end
end


class BaseConfig

  attr_reader :file_path, :data

  def initialize(file_path)
    @file_path = file_path
    generate unless File.exists? @file_path
    load
  end

  def load
    @data = load_hash_from_yaml
  end

  def save(data)
    save_hash_to_yaml(data)
  end

  private

  def generate
    puts "[Notice:] Couldn't find '#{@file_path}' -- Generating a new one."
    stub = {
      :version => VERSION,
      :tasks => {}
    }
    save_hash_to_yaml(stub)
  end

  def save_hash_to_yaml(hash)
    FileUtils.mkdir_p(File.dirname(@file_path))
    File.new(@file_path, "w") unless File.exist? @file_path
    File.open(@file_path, "w") do |yaml_file|
      yaml_file.write(hash.to_yaml)
    end
  end

  def load_hash_from_yaml
    yaml_data = File.open(@file_path, 'r') { |handle| load = YAML.load(handle) }
    yaml_data = {} unless yaml_data
    return yaml_data
  end
end

class Configuration < BaseConfig
  attr_accessor :tasks

  def initialize(file_path)
    super(file_path)
  end

  def load
    super
    @tasks = []
    unless @data[:tasks].empty?
      @data[:tasks].each do |task|
        task_object = Task.new(task.first, task[1][:days], task[1][:commitment])
        @tasks << task_object
      end
    end
  end

  def save_task(task, valid_days, time_commitment)
    @data[:tasks][task] = {:days => valid_days, :commitment => time_commitment}
    save(data)
  end

  def save_context_switch(context_number)
    @data[:current_context] = context_number
    @data[:context_entrance_time] = Time.now.getutc
    save(data)
  end

  def clear_current_context()
    @data[:current_context], @data[:context_entrance_time] = nil, nil
    save(@data)
  end
end

class History < BaseConfig

  def initialize(file_path)
    super(file_path)
  end

  def save_history(task_name, entrance_time, exit_time)
      @data[:tasks][task_name] ||= Array.new
      @data[:tasks][task_name] << [entrance_time, exit_time]
      save(@data)
  end
end

#-------------- Loose methods:

def parse_options
  opts = {}

  # Check first argument, which defines behavior.
  # We can :print, :commit, select a :chosen_context,
  # or define a :new_task.
  case ARGV[0]
  when nil
    opts[:print] = true
  when 'commit'
    opts[:commit] = true
  else
    # Argument doesn't match any commands...
    # So we assume it's a new task definition if alphanumeric,
    # and assume we want to switch context if numeric.
    if !ARGV[0].nan?
      opts[:chosen_context] = ARGV[0]
    else
      opts[:new_task] = ARGV[0]
    end
  end

  # When we define a new task we can specify the days and time inline.
  # For each additional argument, if it's numeric, assume we're specifying the time.
  # If it's alpha, check it against our list of monographs/digraphs/etc
  if opts[:new_task]
    args = ARGV[1..-1]
    opts[:valid_days] = true if args
    args.each do |arg|
      arg = arg.downcase
      if arg.nan?
        key = parse_day_argument(arg)
        if opts[key]
          raise ArgumentError, 'Cannot specify a single day more than one time!'
        else
          opts[key] = true
        end
      else
        if opts[:time]
          raise ArgumentError, 'Can only supply one numerical argument corresponding to commitment time!'
        else
          opts[:time] = arg
        end
      end
    end
  end

  # If commit is true, we have to supply some other arguments:
  # Task name and expected time commitment.
  if opts[:commit]
    # Check for new task definition.
    # Check that ARG 1 exists and that it is NOT numeric.
    name_error_msg = "Must supply task name after 'commit' keyword. (i.e. 'day commit read_hn 0.5')"
    if ARGV[1]
      if ARGV[1].nan?
        opts[:task_name] = ARGV[1]
      else
        raise ArgumentError, error_msg
      end
    else
      raise ArgumentError, error_msg
    end

    # Check for time commitment definition.
    # Check that ARG 2 exists and that it IS numeric.
    time_error_msg = "Must supply expected time commitment after task name. (i.e. 'day commit read_hn 0.5')"
    if ARGV[2]
      if ARGV[2].nan?
        raise ArgumentError, time_error_msg
      else
        opts[:time_commitment] = ARGV[2]
      end
    else
      raise ArgumentError, time_error_msg
    end
  end

  return opts
end

def parse_day_argument(day)
  case day
  when 'su', 'sun', 'sunday', '0'
    return :sunday
  when 'm', 'mo', 'mon', 'monday', '1'
    return :monday
  when 'tu', 'tue', 'tues', 'tuesday', '2'
    return :tuesday
  when 'w', 'we', 'wed', 'wednesday', '3'
    return :wednesday
  when 'th', 'thu', 'thur', 'thurs', 'thursday', '4'
    return :thursday
  when 'f', 'fr', 'fri', 'friday', '5'
    return :friday
  when 'sa', 'sat', 'satu', 'satur', 'saturday', '6'
    return :saturday
  else
    raise ArgumentError, 'Could not parse day argument! Check your day glyphs.'
  end
end

def parse_day_keys(opts)
  days = []
  opts.each do |key, value|
    continue unless value
    case key
    when :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday
      days << key
    end
  end
  return days
end

#-------------- Main control method:

def main

  opts = parse_options

  if opts[:chosen_context]
    histclass = History.new(HISTORY_FILE)
    history_data = histclass.load
  end 

  config = Configuration.new(CONFIG_FILE)
  config_data = config.data

  # Generate list from configuration data:
  list = List.new(config_data[:tasks], config_data[:current_context], config_data[:context_entrance_time]);

  # Handle behaviors:
  if opts[:print]
    list.print
  elsif opts[:chosen_context]
    list.switch(config, histclass, opts[:chosen_context])
  elsif opts[:new_task]
    raise ArgumentError, "Duplicate task." if config_data[:tasks].keys.include? opts[:new_task]
    if opts[:valid_days]
      valid_days = parse_day_keys(opts)
    else
      valid_days = nil
    end
    config.save_task(opts[:new_task], valid_days, opts[:time])
  elsif opts[:commit]
    puts 'commitment'
  else
    raise ArgumentError, "No behavior defined! Check options parsing. "
  end
end

main()



