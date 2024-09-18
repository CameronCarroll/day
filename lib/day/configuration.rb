# DayRB Configuration (Data-Access Layer) Module
#
# Provides convenience methods for database access and holds config data.
#
# MIT License; See LICENSE file; Cameron Carroll 2024

require 'psych'

# Config class handles access to our config file, which mostly just provides a data-access layer.
# Schema:
#   configuration = {
#       context = :task_key,
#       entry_time = :task_start_time
#       tasks = {
#         :key => {
#           :description => (string),
#           :active_days => [(keys of active days)],
#           :estimate => (integer in minutes),
#           :fulfillment => (integer in minutes)
#         }
#       }
#   }

class Configuration
  attr_reader :tasks, :context, :entry_time

  # Load config data from file -- bootstrap it if empty.
  #
  # @param data_file Location of task data file on local drive.
  def initialize(data_file)

    unless File.exist? data_file
      bootstrap_db(data_file)
      puts "day.rb created new config file " + CONFIG_FILE
    end

    if File.exist? data_file
      loaded_data = Psych.safe_load_file(data_file, permitted_classes: [Time, Symbol])
      @context = loaded_data[:context]
      @entry_time = loaded_data[:entry_time]
      @tasks = loaded_data[:tasks]
    else
      puts "Error creating / loading config file"
    end
  end

  # Interface to save_task which decomposes opts hash.
  #
  # @param opts [Hash] options hash containing input data
  def new_task(opts)
    save_task(opts[:task], opts[:description], opts[:days], opts[:estimate])
  end

  # Change context to a different task.
  # (Saves fulfillment for previous task.)
  #
  # @param next_key [String] the name of the task to switch to.
  def switch_to(next_key)
    cap_current_fulfillment if @context
    @context = next_key if @tasks.has_key?(next_key)
    @entry_time = Time.now.getutc
  end

  # Exit context without switching to a new one.
  def clear_context()
    cap_current_fulfillment
    @context, @entry_time = nil, nil
  end

  # Clear fulfillment for one or all tasks.
  #
  # @param task [String] valid task name to specify action for (defaults to all otherwise)
  def clear_fulfillment(task)
    if task
      clear_fulfillment_for task
    else
      @tasks.each do |task, task_data|
        clear_fulfillment_for task
      end
    end
  end

  # Remove a task from config object data.
  # (Note that this doesn't persist to the DBM files by itself...
  # And again, the responsibility for calling save() and closing DB lies
  # with the consumer of this class.)
  #
  # @param task_key [String] Valid task name to delete.
  def delete(task_key)
    @tasks.delete task_key
  end

  # Reload class objects from config data.
  # (Used during testing.)
  def reload()
    @context = @context
    @entry_time = @entry_time

  end

  # To be called at the very end of the script to write data back into YAML
  def save(data_file)
    data = {
      context: @context,
      entry_time: @entry_time,
      tasks: @tasks }
    File.open(data_file, 'w') do |file|
      file.write(Psych.dump(data))
    end
  end

  # Used to verify that a task actually exists and to cross-reference indices to names
  #
  # @param task [String] name or index reference to task
  def lookup_task(task)
    if task.number?
      @tasks.keys[task.to_i]
    else
      task if @tasks.has_key? task
    end
  end

  private

  # Add a new task to the DB.
  #
  # @param task [String] the task name
  # @param description [String] a text description (optional)
  # @param valid_days [Array] contains keys corresponding to the valid days, ie ['monday', 'tuesday'] (optional)
  # @param estimate [String] a time estimate in integer minutes.
  def save_task(task, description, valid_days, estimate)
    if task
      @tasks[task] = {'description' => description, 'valid_days' => valid_days,
       'estimate' => estimate, 'fulfillment' => nil}
    end
  end

  # Builds initial structure for the database file.
  def bootstrap_db(data_file)
    data = {
      context: nil,
      entry_time: nil,
      tasks: {} }

    File.open(data_file, 'w') do |file|
      file.write(Psych.dump(data))
    end
  end

   # Add the elapsed time since entering a context. (Used when exiting that context.)
  def cap_current_fulfillment
    @tasks[@context]['fulfillment'] ||= 0
    @tasks[@context]['fulfillment'] += Time.now - @entry_time
  end

  # Actually modify fulfillment data for a task.
  #
  # @param task [String] Valid task name to verify data for.
  def clear_fulfillment_for(task)
    @tasks[task]['fulfillment'] = nil
  end
end
