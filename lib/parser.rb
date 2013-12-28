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
    when 'help'
      opts[:help] = true
    when 'version'
      opts[:version] = true
    else
      # Argument doesn't match any commands...
      # So we assume it's a new task definition if alphanumeric,
      # and assume we want to switch context if numeric.
      if ARGV[0].number?
        opts[:chosen_context] = ARGV[0]
      else
        opts[:new_task] = ARGV[0]
      end
    end

    if opts[:clear] && ARGV[1]
      opts[:clear_context] = ARGV[1]
    end

    # If delete is true, grab a context number from ARG 1. 
    if opts[:delete]
      delete_error_msg = "You didn't specify what you want to delete. Please supply context number after 'delete' keyword. (i.e. 'day delete 3')"
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
      end
    end

    # When we define a new task we can specify the days and time inline.
    # For each additional argument, if it's numeric, assume we're specifying the time.
    # If it's alpha, check it against our list of monographs/digraphs/etc
    if opts[:new_task]
      # Element 0, the name, was already included as opts[:new_task] value
      ARGV[1..-1].each do |arg|
        if arg =~ /\(.+\)/
          opts[:description] = arg
        elsif arg.downcase == EDITOR
          opts[:editor] = true
        elsif arg.downcase.nan?
          opts[:valid_days] ||= true
          key = parse_day_argument(arg)
          if opts[key]
            raise ArgumentError, "You specified a single day (#{key}) more than once."
          else
            opts[key] = true
          end
        else
          if opts[:time]
            raise ArgumentError, 'You specified more than one time estimate.'
          else
            opts[:time] = arg
          end
        end
      end
    end
    return opts
  end

  def self.parse_day_argument(day)
    case day
    when 'su', 'sun', 'sund', 'sunda', 'sunday', '0'
      return :sunday
    when 'm', 'mo', 'mon', 'mond', 'monda', 'monday', '1'
      return :monday
    when 'tu', 'tue', 'tues', 'tuesd', 'tuesda', 'tuesday', '2'
      return :tuesday
    when 'w', 'we', 'wed', 'wedn', 'wedne', 'wednes', 'wednesd', 'wednesda', 'wednesday', '3'
      return :wednesday
    when 'th', 'thu', 'thur', 'thurs', 'thursd', 'thursda', 'thursday', '4'
      return :thursday
    when 'f', 'fr', 'fri', 'frid', 'frida', 'friday', '5'
      return :friday
    when 'sa', 'sat', 'satu', 'satur', 'saturd', 'saturda', 'saturday', '6'
      return :saturday
    else
      raise ArgumentError, "Couldn't parse which days to enable task. Please double-check glyphs."
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