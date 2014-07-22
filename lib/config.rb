require 'yaml/dbm'

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
  attr_reader :tasks

  def initialize(file_path)
    @db = YAML::DBM.new(file_path)
    bootstrap_db if @db.entries.empty?
    @config = @db.invert
    @tasks = []
  end

  # Build array of task objects from their DB records.
  def load_tasks
    unless @config[:tasks].empty?
      @config[:tasks].each do |task|
        @tasks << Task.new(task.key, task[:description], task[:active_days],
         task[:estimate], task[:fulfillment])
      end
    end
  end

  # Add a new task to the DB.
  # Required: task
  # Optional: description, valid_days, estimate, fulfillment
  def save_task(task, description, valid_days, estimate, fulfillment)
    if task
      @db[task.to_sym] = {:description => description, :valid_days => valid_days,
       :estimate => estimate, :fulfillment => fulfillment}
    end
  end

  # These next two might be candidates for private methods,
  # where we move some of the work currently being handled by list into
  # the public methods in this file.
  # Set DB records to a new current task context.
  def context_switch(next_key)
    @db[:context] = next_key if @db[:tasks].has_key?(next_key)
    @db[:context_entry_time] = Time.now.getutc
  end

  # Exit context without switching to a new one.
  def clear_context()
    @db[:context], @db[:context_entry_time] = nil, nil
  end

  def update_fulfillment(task_key, time)
    if @db[:tasks][task_key][:estimate]
      @db[:tasks][task_key][:fulfillment] ||= 0
      @db[:tasks][task_key][:fulfillment] += time.to_f
    end
  end

  def delete_task(task_key)
    @db[:tasks].delete task_key
  end

  private

  def bootstrap_db
    @db[:context] = nil
    @db[:context_entry_time] = nil
    @db[:tasks] = []
  end
end