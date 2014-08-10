# DayRB Presentation Module
# Handles printouts and error messages.
# MIT License; Cameron Carroll 2014

module Presenter
	class << self

		def print_list(config)
			if config.tasks.empty?
				print_error_empty
			else
				print_task_list(config.tasks)
			end
			context = config.data['context']
			if context
				time = (Time.now - config.data['entry_time']) / 60
				print_current_context(context, time)
			end
		end

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

		def print_help
	    puts <<-eos
	Usage: day.rb <command> [<args>]

	Commands:
	  (no command)              Prints out task list for the day
	  (name of new task)        Creates a new task
	  (index of existing task)  Checks in or out of task according to numerical index
	  delete                    Remove a task
	  info                      Print out descriptions for one or all tasks

	See readme.md for a more detailed overview.
	    eos
	  end

		def print_version
	    puts "Day.rb v#{VERSION}"
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
	    # Convert fulfillment and estimate values into minutes:
	    fulfillment /= 60 if fulfillment
	    estimate /= 60 if estimate


	    if fulfillment
	      diff = fulfillment.to_f / estimate.to_f * 100
	      print " [#{'%2.1f' % fulfillment}".color_completion + "/#{estimate} minutes]".color_text
	      print " [#{'%2.1f' % diff}%]".color_completion
	    elsif estimate
	      print " (#{estimate} minute estimate)".color_text
	    end
	  end

	  def print_description(task_name, task_object)
	  	print "Description for #{task_name}: "
	  	puts task_object.description
	  end

	  def print_current_context(context, time)
	  	puts "Current task: #{context} (#{'%2.1f' % time} minutes)"
	  end

	  def print_error_empty()
	  	puts "The task list is empty!"
	  end

		def print_error_unknown()
			puts "Sorry, that command is not known. Try 'help'."
		end
	end
end