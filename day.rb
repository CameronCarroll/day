#!/usr/bin/ruby

# Script File: day.rb
# Author: Cameron Carroll; Created July 2013
# Purpose: Main file for day.rb time tracking app.

require 'rubygems'
require 'bundler/setup'

require 'trollop'
require 'pry'

VERSION = '0.1.1'
CONFIG_FILE = ENV['HOME'] + '/.TODO'
HISTORY_FILE = ENV['HOME'] + '/.TODO_HISTORY'

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
    stub_config = {
      :version => VERSION,
      :tasks => []
    }
    save_yaml_data(stub_config, @config_path)
  end

  def generate_history
    stub_history = {
      :VERSION => VERSION,
      :task_history => {

      }
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
    puts "Tasks:"
    counter = 0
    @config_data[:tasks].each do |task|
      puts counter.to_s + ': ' + task[:name]
      counter = counter + 1
    end
  end

  def create_task(name, days)
    puts @config_data
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
    @history_data[:task_history][task_name] = Array.new unless @history_data[:task_history].has_key? @current_context
    @history_data[:task_history][task_name] << [@context_entrance_time, Time.now.getutc]
    binding.pry
    save_history
    @current_context, @context_entrance_time = nil, nil
  end 

end

def main
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
      list.enter_context(ARGV.first)
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