require 'yaml/dbm'
require_relative 'task'
require 'pry'

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
  attr_reader :tasks, :context, :entry_time

  def initialize(db)
    @db = db
    @data = @db.to_hash
    bootstrap_db if @data.empty?
    @tasks = load_tasks
  end

  # Add a new task to the DB.
  # Required: task
  # Optional: description, valid_days, estimate, fulfillment
  def save_task(task, description, valid_days, estimate)
    if task
      @data['tasks'][task] = {'description' => description, 'valid_days' => valid_days,
       'estimate' => estimate, 'fulfillment' => nil}
    end
  end

  # These next two might be candidates for private methods,
  # where we move some of the work currently being handled by list into
  # the public methods in this file.
  # Set DB records to a new current task context.
  def context_switch(next_key)
    @data['context'] = next_key if @data['tasks'].has_key?(next_key)
    @data['entry_time'] = Time.now.getutc
  end

  # Exit context without switching to a new one.
  def clear_context()
    @data['context'], @data['entry_time'] = nil, nil
  end

  def update_fulfillment(task_key, time)
    if @data['tasks'][task_key]['estimate']
      @data['tasks'][task_key]['fulfillment'] ||= 0
      @data['tasks'][task_key]['fulfillment'] += time.to_f
    end
  end

  def delete_task(task_key)
    @data['tasks'].delete task_key
  end

  def reload()
    @tasks = load_tasks
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

  def bootstrap_db
    @data['context'] = nil
    @data['entry_time'] = nil
    @data['tasks'] = {}
  end
end