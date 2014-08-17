# DayRB Tasklist Module
#
# MIT License; See LICENSE file; Cameron Carroll 2014

require_relative 'task'

# DayRB Tasklist Module
#
# Responsible for loading tasks.
# Mainly to manage a list of tasks which are valid today,
# but also allow us to use the '-a' option.
class Tasklist
	attr_reader :all_tasks, :valid_tasks

	def initialize(config)
		@config = config
		@all_tasks = load_tasks(config.data['tasks'])
		today = Time.new.strftime("%A").downcase.to_sym
		@valid_tasks = @all_tasks.select do |task_name, task_object|
			if task_object.valid_days
				task_object.valid_days.include? today
			else
				true
			end
		end
	end

	private

	# Build array of task objects from their DB records.
	#
	# @param tasks [Hash] Collection of task_name => task_hash pairs
	def load_tasks(tasks)
	  task_objects = {}
	  unless tasks.empty?
	    tasks.each do |task_name, task|
	      task_objects[task_name] = Task.new(task_name, task['description'], task['valid_days'],
	       task['estimate'], task['fulfillment'])
	    end
	  end

	  return task_objects
	end
end