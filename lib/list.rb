EMPTY_ERROR_MSG = "(No tasks in list.)"
class List

  attr_accessor :tasks, :current_context, :context_entrance_time

  def initialize(task_list, current_context, context_entrance_time)
    @tasks = []
    if task_list
      task_list.each do |task|
        #task.first refers to the key (task name), since the task is stored [key, val] and key = name
        #[:day_fulfillment][0] is the date and [1] is the accumulator.
        task_instance = Task.new(task.first, task[1][:days], task[1][:description], task[1][:estimate], task[1][:fulfillment], task[1][:day_fulfillment])
        @tasks << task_instance if task_instance.valid_today?
      end
    end

    @current_context = current_context if current_context
    @context_entrance_time = context_entrance_time if context_entrance_time
  end

  def printout
    print_tasklist(DESCRIPTION_FLAG)
    if @current_context
      current_task = find_task_by_number(@current_context)
      time_difference_minutes = (Time.now.getutc - @context_entrance_time) / 60
      time_diff_today = current_task.day_fulfillment + time_difference_minutes if current_task.day_fulfillment
      print "Current task: ".color_title + " (#{@current_context}) ".color_text + current_task.name.color_text
      if current_task.time_estimate
        print_fulfillment(time_difference_minutes, current_task.time_estimate, time_diff_today)
      else
        puts "\n"
        print_time(time_difference_minutes)
      end
      puts "\n"
    end
  end

  # description_flag:
  #   :no_description -- prints out a star beside task name
  #   :description    -- prints out full description
  def print_tasklist(description_flag)
    if @tasks.empty?
      puts EMPTY_ERROR_MSG
    else
      ii = 0
      @tasks.each_with_index do |task, ii|
        print ii.to_s + ': ' + task.name
        print "*".color_star if task.description && (description_flag == :no_description)
        print_fulfillment(task.fulfillment, task.time_estimate, task.day_fulfillment)
        if task.description && (description_flag == :description)
          print_description(task.description)
        end
        
      end
    end
    
  end

  def print_descriptions
    if @tasks.empty?
      puts EMPTY_ERROR_MSG
    else
      @tasks.each_with_index do |task, ii|
        if task.description
          print ii.to_s + ': ' + task.name.color_text + "\n"
          print_description(task.description)
        end
      end
    end
  end

  # Overloaded Function:
  # ------------------------------------------------------
  # 1: print_description(description) --
  #     Declares `Description:' before printing it out.
  # 2: print_description(title, description) --
  #     Desclares `{Title}:' before printing it out.
  def print_description(*args)
    if args.length == 1
      description = args[0]
      print "Description: ".color_title
      puts description.color_text
    else
      title = args[0]
      description = args[1]
      print "#{title}: ".color_title
      puts description.color_text
    end
  end

  def print_fulfillment(fulfillment, estimate, day_fulfillment)
    if fulfillment
      diff = fulfillment.to_f / estimate.to_f * 100
      print " [#{'%2.1f' % fulfillment}".color_completion + "/#{estimate} minutes]".color_text
      print " [#{'%2.1f' % diff}%]".color_completion
    elsif estimate
      print " (#{estimate} minute estimate)".color_text
    end

    if day_fulfillment
      puts " {#{'%2.1f' % day_fulfillment} minutes today}".color_completion
    else
      puts ""
    end
  end

  def print_time(time_difference)
    print "Time: ".color_title
    puts ('%.1f' % (time_difference)).to_s.color_text + " minutes.".color_text
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

  def switch(config, histclass, context_number)

    if @tasks.empty?
      raise RuntimeError, "No tasks are defined."
    end

    unless (0..@tasks.size-1).member?(context_number.to_i)
      raise ArgumentError, "Choice is out of bounds! Didn't find a task at that index."
    end

    unless @current_context
      task = find_task_by_number(context_number)
      puts "Enter context: #{task.name}".color_context_switch
      print_description(task.description) if task.description
      config.save_context_switch(context_number)
    end

    if @current_context == context_number
      current_task = find_task_by_number(@current_context)
      puts "Exit Context: #{current_task.name}".color_context_switch
      time_difference = (Time.now.getutc - @context_entrance_time) / 60
      config.update_fulfillment(current_task.name, time_difference)
      print_time(time_difference)
      histclass.save_history(current_task.name, @context_entrance_time, Time.now.getutc)
      config.clear_current_context
      return
    end

    if @current_context && @context_entrance_time
      current_task = find_task_by_number(@current_context)
      puts "Exit context: #{current_task.name}".color_context_switch
      time_difference = (Time.now.getutc - @context_entrance_time) / 60
      print_time(time_difference)
      config.update_fulfillment(current_task.name, time_difference)
      new_task = find_task_by_number(context_number)
      puts "\nEnter context: #{new_task.name}".color_context_switch
      print_description(new_task.description) if new_task.description
      histclass.save_history(current_task.name, @context_entrance_time, Time.now.getutc)
      config.clear_current_context
      config.save_context_switch(context_number)
    end
  end



  def find_task_by_number(numeric_selection)
    if @tasks[numeric_selection.to_i]
      return @tasks[numeric_selection.to_i]
    else
      return nil
    end
  end

  def clear_fulfillments(config)
    config.data[:tasks].each do |key, value|
      value[:fulfillment] = nil
      value[:day_fulfillment] = nil
    end
    config.save_self
  end

  # Overloaded Function:
  # ------------------------------------------------------
  # 1: clear_fulfillment(config) --
  #     Clear all fulfillment data.
  # 2: clear_fulfillment(config, task_name) --
  #     Clear only data for a single task.
  def clear_fulfillment(*args)
    config = args.first
    if args.length == 1
      config.data[:tasks].each do |key, value|
        value[:fulfillment] = nil
        value[:day_fulfillment] = nil
      end
      config.save_self
    else
      task_name = args[1]
      config.data[:tasks][task_name][:fulfillment] = nil
      config.data[:tasks][task_name][:day_fulfillment] = nil
      config.save_self
    end
  end

end