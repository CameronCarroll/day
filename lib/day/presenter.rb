# DayRB Presentation Module
#
# Handles printouts and error messages.
# Also adds colorization as specified in main file.
#
# MIT License; See LICENSE file; Cameron Carroll 2014

module Presenter
	class << self

		# Prints out task list and current context, if applicable.
		#
		# @param tasklist [Hash] Hash of task_name => task_object pairs
		# @param context [String] Name of current task context
		# @param time [String] Elapsed time since starting current task.
		def print_list(tasklist, context, time)
			if tasklist.empty?
				print_error_empty
			else
				print_task_list(tasklist)
			end
			if context
				print_current_context(context, time)
			end
		end

		# Prints info for a specific task if provided.
		# If not, prints out every description for tasks that have one.
		#
		# @param tasklist [Hash] Hash of task_name => task_object pairs
		# @param task [String] Name of specific task to print info for.
		def print_info(tasklist, task)
			if task
				task_object = tasklist[task]
				if task_object.description
					print_description task, task_object
				else
					puts "There was no description for #{task}."
				end
			else
				tasklist.each do |task_name, task_object|
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
	  #
	  # @param task [String] Name of task to be deleted
	  # @param description [String] Description of task (optional)
	  def announce_deletion(task, description)
	  	puts "Deleted #{task}".color_text
	  	puts "Description was: #{description}".color_text if description
	  end

	  # Announces that either a task or all tasks have had fulfillment cleared.
	  #
	  # @param task [String] Name of task to be cleared
	  def announce_clear(task)
	  	if task
	  		puts "Cleared fulfillment for #{task}".color_text
	  	else
	  		puts "Cleared fulfillment for all tasks".color_text
	  	end
	  end

	  # Announces a switch to a new task...
	  # also prints the amount of time spent on the old one.
	  #
	  # @param task [String] Name of task to switch to
	  # @param old_task [String] Name of current context, before switching
	  # @param old_time [String] Time spent since starting old_task
	  def announce_switch(task, old_task, old_time)
	  	puts "Switching to #{task}"
	  	if old_task && old_time
	  		puts "(Spent #{convert_time_with_suffix old_time} on #{old_task})"
	  	end
	  end

	  # Announces that we leave current context, prints out time spent.
	  # Used when not starting a new task.
	  #
	  # @param old_task [String] Name of current context
	  # @param old_time [String] Time spent since starting old_task
	  def announce_leave_context(old_task, old_time)
	  	puts "Stopping tracking for #{old_task}"
	  	puts "(Spent #{convert_time_with_suffix old_time})"
	  end

	  # Announces the creation of a new task.
	  #
	  # @param task [String] Name of task to be added
	  def announce_new_task(task)
	  	puts "Added new task, #{task}"
	  end

		private

		# Iterate through tasklist, printing index, name, description flag and fulfillment/estimate data.
		#
		# @param tasks [Hash] Collection of task_name => task_object pairs
		def print_task_list(tasks)
			ii = 0
			# indexing the hash as an array
			# task[0] contains key (task name)
			# task[1] contains task object
			tasks.each_with_index do |task, ii|
				task_name = task[0]
				task_object = task[1]
				print ii.to_s.color_index + ': ' + task_name.color_task
	      print "*".color_star if task_object.description
	      print_fulfillment(task_object.fulfillment, task_object.time_estimate)
	      puts "\n"
			end
		end

		# Print/format fulfillment and estimate data.
		#
		# @param fulfillment [Integer] Time spent on task in seconds
		# @param estimate [Integer] Estimated time for task in seconds
		def print_fulfillment(fulfillment, estimate)
			if fulfillment
				if estimate
					diff = fulfillment.to_f / estimate.to_f * 100
					print " [#{convert_time(fulfillment)}".color_completion + "/#{convert_time_with_suffix(estimate)}]".color_text
					print " [#{'%2.1f' % diff}%]".color_completion
				else
					print " [#{convert_time_with_suffix(fulfillment)}]"
				end
			elsif estimate
				print " (#{convert_time_with_suffix(estimate)} estimate)"
			end
	  end

	  # Print task name and description.
	  #
	  # @param task_name [String] Name of task
	  # @param task_object [Task] Task object to print description for
	  def print_description(task_name, task_object)
	  	print "Description for #{task_name}: "
	  	puts task_object.description
	  end

	  # Print information about the current task.
	  #
	  # @param context [String] Name of current task
	  # @param time [Integer] Time spent on current task in seconds
	  def print_current_context(context, time)
	  	puts "Current task: #{context} (#{convert_time_with_suffix(time)})"
	  end

	  # Convert seconds into a more appropriate amount.
	  # Hours and days also return the leftover minutes and hours, respectively.
	  #
	  # @param seconds [Integer] Time to be converted in seconds.
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

	  # Formats the results of convert_time into a human-readable string.
	  #
	  # @param seconds [Integer] Time to be converted in seconds.
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

	  # Print empty-tasklist error.
	  def print_error_empty()
	  	puts "The task list is empty!"
	  end

	  # Print unknown error.
		def print_error_unknown()
			puts "Sorry, that command is not known. Try 'help'."
		end
	end
end