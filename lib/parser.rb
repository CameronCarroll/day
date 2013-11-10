module Parser

  def self.parse_options
      opts = {}
    # Check first argument, which defines behavior.
    # We can :print, :clear, :delete, select a :chosen_context,
    # or define a :new_task.
    case ARGV[0]
    when nil
      opts[:print] = true
    when 'clear', 'c'
      opts[:clear] = true
    when 'delete', 'rm'
      opts[:delete] = true
    when 'info', 'i'
      opts[:info] = true
    else
      # Argument doesn't match any commands...
      # So we assume it's a new task definition if alphanumeric,
      # and assume we want to switch context if numeric.
      if !ARGV[0].nan?
        opts[:chosen_context] = ARGV[0]
      else
        opts[:new_task] = ARGV[0]
      end
    end


    # When we define a new task we can specify the days and time inline.
    # For each additional argument, if it's numeric, assume we're specifying the time.
    # If it's alpha, check it against our list of monographs/digraphs/etc
    if opts[:new_task]
      remaining_arg_index = 1
      if ARGV[1] =~ /\(.+\)/
        opts[:description] = ARGV[1]
        remaining_arg_index = 2
      end
      args = ARGV[remaining_arg_index..-1]
      opts[:valid_days] = true if args
      args.each do |arg|
        arg = arg.downcase
        if arg.nan?
          key = parse_day_argument(arg)
          if opts[key]
            raise ArgumentError, 'Cannot specify a single day more than one time!'
          else
            opts[key] = true
          end
        else
          if opts[:time]
            raise ArgumentError, 'Can only supply one numerical argument corresponding to estimate time!'
          else
            opts[:time] = arg
          end
        end
      end
    end

    # If delete is true, grab a context number from ARG 1. 
    if opts[:delete]
      delete_error_msg = "Must supply context number after 'delete' keyword. (i.e. 'day delete 3')"
      if ARGV[1]
        # Have to check if it's a valid context somewhere else...
        opts[:chosen_context] = ARGV[1]
      else
        raise ArgumentError, delete_error_msg
      end
    end

    if opts[:info]
      if ARGV[1]
        opts[:info_context] = ARGV[1]
      else
        raise ArgumentError, "Must supply task number for which we should print the description. (i.e. 'day info 2')"
      end
    end

    # If commit is true, we have to supply some other arguments:
    # Task name and expected time estimate.
    if opts[:commit]
      # Check for new task definition.
      # Check that ARG 1 exists and that it is NOT numeric.
      name_error_msg = "Must supply task name after 'commit' keyword. (i.e. 'day commit read_hn 0.5')"
      if ARGV[1]
        if ARGV[1].nan?
          opts[:task_name] = ARGV[1]
        else
          raise ArgumentError, error_msg
        end
      else
        raise ArgumentError, error_msg
      end

      # Check for time estimate definition.
      # Check that ARG 2 exists and that it IS numeric.
      time_error_msg = "Must supply expected time estimate after task name. (i.e. 'day commit read_hn 0.5')"
      if ARGV[2]
        if ARGV[2].nan?
          raise ArgumentError, time_error_msg
        else
          opts[:time_estimate] = ARGV[2]
        end
      else
        raise ArgumentError, time_error_msg
      end
    end

    return opts
  end

  def self.parse_day_argument(day)
    case day
    when 'su', 'sun', 'sunday', '0'
      return :sunday
    when 'm', 'mo', 'mon', 'monday', '1'
      return :monday
    when 'tu', 'tue', 'tues', 'tuesday', '2'
      return :tuesday
    when 'w', 'we', 'wed', 'wednesday', '3'
      return :wednesday
    when 'th', 'thu', 'thur', 'thurs', 'thursday', '4'
      return :thursday
    when 'f', 'fr', 'fri', 'friday', '5'
      return :friday
    when 'sa', 'sat', 'satu', 'satur', 'saturday', '6'
      return :saturday
    else
      raise ArgumentError, 'Could not parse day argument! Check your day glyphs.'
    end
  end

  def self.parse_day_keys(opts)
    days = []
    opts.each do |key, value|
      continue unless value
      case key
      when :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday
        days << key
      end
    end
    return days
  end
end