# DayRB Parser Module
#
# Parses and validates ARGV.
# After validation, we can confidently assume a specified task in opts exists.
#
# MIT License; See LICENSE file; Cameron Carroll 2014

require 'abbrev'

E_NO_SUCH_TASK = "I didn't find any task by that name."
E_MUST_SPECIFY_TASK = "I need you to specify which task to delete."

# DayRB Parser Module
#
# Scans and validates ARGV inputs and builds the opts hash.
# (Performs argument validation, and checks that a specified task really exists.)
module Parser
  class << self

    # Parse ARGV into opts hash
    #
    # @param config [Configuration] Entire configuration object, needed for task lookups.
    def parse_options(config)
      opts = {}
      @config = config

      opts[:operation] = case ARGV.first
      when nil
        :print
      when "-a", "-A"
        opts[:all] = true
        :print
      when "clear", "c"
        :clear
      when "delete", "rm"
        :delete
      when "info", "i"
        :print_info
      when "help"
        :print_help
      when "version"
        :print_version
      else
        handle_non_command(ARGV.first) # could either be a new task or switch to an existing one
      end

      opts[:task] = case opts[:operation]
      when :clear, :print_info
        check_for_second_argument
      when :delete
        demand_second_argument
      when :switch
        task = lookup_task(ARGV.first)
        if task && @config.data['context'] == task
          opts[:operation] = :leave
          nil
        elsif task
          task
        else
          raise ArgumentError, E_NO_SUCH_TASK
        end
      when :new
        ARGV.first
      end

      if opts[:operation] == :new
        opts = handle_new_task(opts)
      end

      opts.delete_if { |k, v| v.nil? }
      return opts
    end

    private

    # Determine if a non-command argument corresponds to a :switch or a :new task
    def handle_non_command(argument)
      if argument.number? || lookup_task(argument) # then we switch to that task index or name
        :switch
      else # then we assume it's a new task to be created.
        :new
      end
    end

    # Check for ARGV[1] but don't raise error if it doesn't exist.
    # But if we find a task name/index, we make sure it is valid.
    def check_for_second_argument
      if ARGV[1]
        task = lookup_task(ARGV[1])
        if task
          task
        else
          raise ArgumentError, E_NO_SUCH_TASK
        end
      end
    end

    # Checks for second argument, but raises error if it doesn't exist.
    def demand_second_argument
      argument = check_for_second_argument
      if argument
        argument
      else
        raise ArgumentError, E_MUST_SPECIFY_TASK
      end
    end

    # Check config data either for a task name or index.
    def lookup_task(name)
      @config.lookup_task(name)
    end

    # Gather remaining options for a new task
    # Checks for a description (or a mention of EDITOR),
    # valid days, and a time estimate.
    def handle_new_task(opts)
      ARGV[1..-1].each do |arg|
        if arg =~ /\(.+\)/
          next if opts[:editor]
          opts[:description] = arg
        elsif arg.downcase == EDITOR
          opts[:editor] = true
          opts[:description] = ''
          tempfile = 'dayrb_description.tmp'
          system("#{EDITOR} #{tempfile}")
          input = ""
          begin
            File.open(tempfile, 'r') do |tempfile|
              while (line = tempfile.gets)
                opts[:description] << line.chomp
              end
            end

            File.delete tempfile
          rescue => err
            raise ArgumentError, err
          end
        elsif arg.downcase.nan?
          opts[:days] ||= []
          key = parse_day_argument(arg)
          if opts[:days].include? key
            raise ArgumentError, "You specified a single day (#{key}) more than once."
          else
            opts[:days] << key
          end
        else
          if opts[:estimate]
            raise ArgumentError, 'You specified more than one time estimate.'
          else
            opts[:estimate] = arg.to_i * 60# convert to seconds for storage
          end
        end
      end

      return opts
    end

    # Check a possible valid-day argument against abbreviation list.
    def parse_day_argument(day)
      abbreviations = Abbrev.abbrev(%w{sunday monday tuesday wednesday thursday friday saturday})
      if abbreviations.has_key? day
        return abbreviations[day].to_sym
      else
        raise ArgumentError, "Couldn't parse which days to enable task."
      end
    end
  end
end