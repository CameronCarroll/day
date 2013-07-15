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
  attr_accessor :config_data, :config_file_path

  def initialize(config_filename)
    generate_configuration(config_filename) unless File.exists? config_filename
    @config_data = load_configuration(config_filename)
  end

  def generate_configuration(filename)
    stub_config = {
      'VERSION' => '0.1.1',
      'tasks' => []
    }
    File.new(filename, "w")
    File.open(filename, "w") do |yaml_file|
      yaml_file.write(stub_config.to_yaml)
    end
  end

  def load_configuration(filename)
    config_data = File.open(filename, 'r') { |handle| load = YAML.load(handle) }
    return config_data
  end

  def save_configuration(filename)
    File.open(filename, "w") do |yaml_file|
      yaml_file.write(@config_data.to_yaml)
    end
  end

  def print
    puts "Tasks:"
    counter = 0
    @config_data['tasks'].each do |task|
      puts counter.to_s + ': ' + task[:name]
      counter = counter + 1
    end
  end

  def create_task(name, days)
    puts @config_data
    @config_data['tasks'] << { :name => name, :days => days}
    self.save_configuration(CONFIG_FILE)
  end

end

def main
	opts = parse_options
  list = DayList.new(CONFIG_FILE)
  if !opts[:new]
    list.print
  elsif opts[:new] && !opts[:name] && !opts[:days]
    # call new task wizard
  elsif opts[:new] && opts[:name] && !opts[:days]
    list.create_task(opts[:name], nil)
  elsif opts[:new] && opts[:name] && opts[:days]
    list.create_task(opts[:name], opts[:days])
  end
end

main()