require 'yaml/dbm'
require_relative 'task'

# Config class handles access to our config file, which mostly just stores
# tasks for the moment.
# We need to be able to load tasks from the config file, add & delete a task.
# We also want to keep track of the current context and fulfillments.
# Schema:
#   configuration = {
#       current_context = :task_key,
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
  attr_reader :data, :tasks, :context, :entry_time

  # @param db [PSYCH::DBM] database (hash-like) initialized and closed by caller.
  def initialize(db)
    @db = db
    @data = @db.to_hash
    bootstrap_db if @data.empty?
    @tasks = load_tasks
  end

  # Interface to save_task which decomposes opts hash.
  # @param opts [Hash] options hash containing input data
  def new_task(opts)
    save_task(opts[:task], opts[:description], opts[:days], opts[:estimate])
  end

  # These next two might be candidates for private methods,
  # where we move some of the work currently being handled by list into
  # the public methods in this file.

  # Set DB records to a new current task context.
  #
  # @param next_key [String] the name of the task to switch to.
  def switch_to(next_key)
    @data['context'] = next_key if @data['tasks'].has_key?(next_key)
    @data['entry_time'] = Time.now.getutc
  end

  # Exit context without switching to a new one.
  def clear_context()
    @data['context'], @data['entry_time'] = nil, nil
  end

  # Add time to a task's fulfillment field.
  #
  # @param task_key [String] name of task to update
  # @param time [String] amount of time (integer minutes) to add
  def update_fulfillment(task_key, time)
    if @data['tasks'][task_key]['estimate']
      @data['tasks'][task_key]['fulfillment'] ||= 0
      @data['tasks'][task_key]['fulfillment'] += time.to_f
    end
  end

  # Remove a task from list. Doesn't persist until save_data()
  def delete(task_key)
    @data['tasks'].delete task_key
  end

  # Used for tests, but I realize now that by writing the test this way,
  # we don't actually check the persistence layer! We're just grabbing the
  # @data we just saved and running it through the load function again.

  # Reload task objects from config data.
  def reload()
    @tasks = load_tasks
  end

  # To be called at the very end of the script to write data back into YAML::DBM
  def save()
    @db.update(@data)
  end

  # Used to verify that a task actually exists and to cross-reference indices to names
  # @param task [String] can either be a task name or index to reference by
  def lookup_task(task)
    if task.number?
      @tasks.keys[task.to_i]
    else
      task if @tasks.has_key? task
    end
  end

  private

  # Build array of task objects from their DB records.
  def load_tasks
    tasks = {}
    unless @data['tasks'].empty?
      @data['tasks'].each do |task_name, task|
        tasks[task_name] = Task.new(task_name, task['description'], task['active_days'],
         task['estimate'], task['fulfillment'])
      end
    end

    return tasks
  end

  # Add a new task to the DB.
  #
  # @param task [String] the task name
  # @param description [String] a text description (optional)
  # @param valid_days [Array] contains keys corresponding to the valid days, ie ['monday', 'tuesday'] (optional)
  # @param estimate [String] a time estimate in integer minutes.
  def save_task(task, description, valid_days, estimate)
    if task
      @data['tasks'][task] = {'description' => description, 'valid_days' => valid_days,
       'estimate' => estimate, 'fulfillment' => nil}
    end
  end

  # Builds initial structure for the database file.
  def bootstrap_db
    @data['context'] = nil
    @data['entry_time'] = nil
    @data['tasks'] = {}
  end
end