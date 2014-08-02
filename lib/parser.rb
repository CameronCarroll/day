require 'abbrev'
require 'pry'

E_NO_SUCH_TASK = "I didn't find any task by that name."
E_MUST_SPECIFY_TASK = "I need you to specify which task to delete."

module Parser
  @config = nil

  class << self

    def parse_options(config)
      opts = {}
      @config = config

      opts[:operation] = case ARGV.first
      when nil
        :print
      when "clear", "c"
        :clear
      when "delete", "rm"
        :delete
      when "info", "i"
        :info
      when "help"
        :help
      when "version"
        :version
      else
        handle_non_command(ARGV.first) # could either be a new task or switch to an existing one
      end

      opts[:task] = case opts[:operation]
      when :clear, :info
        check_for_second_argument
      when :delete
        demand_second_argument
      when :switch
        task = lookup_task(ARGV.first)
        if task
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

    def handle_non_command(argument)
      if argument.number? || lookup_task(argument) # then we switch to that task index or name
        :switch
      else # then we assume it's a new task to be created.
        :new
      end
    end

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

    def demand_second_argument
      argument = check_for_second_argument
      if argument
        argument
      else
        raise ArgumentError, E_MUST_SPECIFY_TASK
      end
    end

    def lookup_task(name)
      @config.lookup_task(name)
    end

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

    def parse_day_argument(day)
      abbreviations = Abbrev.abbrev(%w{sunday monday tuesday wednesday thursday friday saturday})
      if abbreviations.has_key? day
        return abbreviations[day].to_sym
      else
        raise ArgumentError, "Couldn't parse which days to enable task."
      end
    end

    def parse_day_keys(opts)
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
end