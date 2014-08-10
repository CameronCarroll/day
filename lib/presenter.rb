# DayRB Presentation Module
# Handles printouts and error messages.
# MIT License; Cameron Carroll 2014

module Presenter
	class << self

		# Prints out task list and current context, if applicable.
		def print_list(config)
			if config.tasks.empty?
				print_error_empty
			else
				print_task_list(config.tasks)
			end
			context = config.data['context']
			if context
				time = (Time.now - config.data['entry_time'])
				print_current_context(context, time)
			end
		end

		# Prints info for a specific task if provided.
		# If not, prints out every description for tasks that have one.
		def print_info(config, task)
			if task
				task_object = config.tasks[task]
				if task_object.description
					print_description task, task_object
				else
					puts "There was no description for #{task}."
				end
			else
				config.tasks.each do |task_name, task_object|
					print_description task_name, task_object if task_object.description
				end
			end
		end

		# Prints out program help string
		def print_help
	    puts <<-eos
Usage: day.rb <command> [<args>]

Commands:
  (no command)        Prints out task list for the day
  (nonexisting task)  Creates a new task
  (existing task)     Start tracking time for named task.
  delete (task)       Remove a task
  info                Print all descriptions
  info (task)         Print a specific description
  clear               Clear fulfillment for all tasks.
  clear (task)        Clear fulfillment for a specific task.

Refer to a task either by its name or index.
See readme.md for a more detailed overview.
	    eos
	  end

	  # Prints out the VERSION constant
		def print_version
	    puts "Day.rb v#{VERSION}"
	  end

	  # Announces task has been deleted and prints its description if applicable.
	  def announce_deletion(task, description)
	  	puts "Deleted #{task}".color_text
	  	puts "Description was: #{description}".color_text if description
	  end

	  # Announces that either a task or all tasks have had fulfillment cleared.
	  def announce_clear(task)
	  	if task
	  		puts "Cleared fulfillment for #{task}".color_text
	  	else
	  		puts "Cleared fulfillment for all tasks".color_text
	  	end
	  end

	  # Announces a switch to a new task and the amount of time spent on the old one.
	  def announce_switch(task, old_task, old_time)
	  	puts "Switching to new task, #{task}"
	  	if old_task && old_time
	  		puts "(Spent #{convert_time_with_suffix old_time} on #{old_task})"
	  	end
	  end

	  # Announces that we leave current context, prints out time spent.
	  # Used when not starting a new task.
	  def announce_leave_context(old_task, old_time)
	  	puts "Stopping tracking for #{old_task}"
	  	puts "(Spent #{convert_time_with_suffix old_time})"
	  end

	  # Announces the creation of a new task.
	  def announce_new_task(task)
	  	puts "Added new task, #{task}"
	  end

		private

		def print_task_list(tasks)
			ii = 0
			tasks.each_with_index do |task, ii|
				name = task.first
				task = task[1]
				print ii.to_s.color_index + ': ' + name.color_task
	      print "*".color_star if task.description && (DESCRIPTION_FLAG == :no_description)
	      print_fulfillment(task.fulfillment, task.time_estimate)
	      if task.description && (DESCRIPTION_FLAG == :description)
	        print_description(task.description)
	      end
	      puts "\n"
			end
		end

		def print_fulfillment(fulfillment, estimate)
			if fulfillment
				if estimate
					diff = fulfillment.to_f / estimate.to_f * 100
					print " [#{convert_time(fulfillment)}".color_completion + "/#{convert_time_with_suffix(estimate)}]".color_text
					print " [#{'%2.1f' % diff}%]".color_completion
				else
					print " (#{convert_time_with_suffix(fulfillment)})"
				end
			elsif estimate
				print " (#{convert_time_with_suffix(estimate)} estimate)"
			end
	  end

	  def print_description(task_name, task_object)
	  	print "Description for #{task_name}: "
	  	puts task_object.description
	  end

	  def print_current_context(context, time)
	  	puts "Current task: #{context} (#{convert_time_with_suffix(time)})"
	  end

	  def convert_time(seconds)
	  	if seconds < 60
	  		return ('%1.0f' % seconds)
	  	elsif seconds >= 60 && seconds < 3600
	  		return ('%2.1f' % (seconds/60))
	  	elsif seconds >= 3600 && seconds < 86400
	  		hours = seconds / 3600
	      leftover_minutes = seconds % 3600 / 60
	      return ('%1.0f' % hours), ('%2.1f' % leftover_minutes)
	  	elsif seconds >= 86400
	  		days = seconds / 86400
	      leftover_hours = seconds % 86400 / 3600
	      return ('%1.0f' % days), ('%2.1f' % leftover_hours)
	  	end
	  end

	  def convert_time_with_suffix(seconds)
	  	first_result, second_result = convert_time(seconds)
	    if seconds < 60
	      "#{first_result} seconds"
	    elsif seconds >= 60 && seconds < 3600
	      "#{first_result} minutes"
	    elsif seconds >= 3600 && seconds < 86400
	      "#{first_result} hours and #{second_result} minutes"
	    elsif seconds >= 86400
	      "#{first_result} days and #{second_result} hours"
	    end
	  end

	  def print_error_empty()
	  	puts "The task list is empty!"
	  end

		def print_error_unknown()
			puts "Sorry, that command is not known. Try 'help'."
		end
	end
end