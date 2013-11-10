class Configuration < BaseConfig
  attr_accessor :tasks

  def initialize(file_path)
    super(file_path)
  end

  def load
    super
    @tasks = []
    unless @data[:tasks].empty?
      @data[:tasks].each do |task|
        task_yday = task[1][:day_fulfillment][0] if task[1][:day_fulfillment]
        today_yday = Time.new.yday
        if task_yday && task_yday == today_yday
          task_object = Task.new(task.first, task[1][:days], task[1][:description], task[1][:estimate], task[1][:fulfillment], task[1][:day_fulfillment])
          @tasks << task_object
        else
          task_object = Task.new(task.first, task[1][:days], task[1][:description], task[1][:estimate], task[1][:fulfillment], nil)
          @data[:tasks][task.first][:day_fulfillment] = nil
        end 
      end
    end
  end

  def save_task(task, valid_days, description, time_estimate, fulfillment, day_fulfillment)
    puts "Creating new task: ".color_title + task
    @data[:tasks][task] = {:days => valid_days, :description => description, :estimate => time_estimate, :fulfillment => fulfillment, :day_fulfillment => day_fulfillment}
    save(data)
  end

  def save_context_switch(context_number)
    @data[:current_context] = context_number
    @data[:context_entrance_time] = Time.now.getutc
    save(data)
  end

  def clear_current_context()
    @data[:current_context], @data[:context_entrance_time] = nil, nil
    save(@data)
  end

  def update_fulfillment(task_name, time)
    if @data[:tasks][task_name][:day_fulfillment].nil? || @data[:tasks][task_name][:day_fulfillment].empty?
      @data[:tasks][task_name][:day_fulfillment] ||= Array.new
      @data[:tasks][task_name][:day_fulfillment][0] = Time.new.yday
      @data[:tasks][task_name][:day_fulfillment][1] = time
    elsif @data[:tasks][task_name][:day_fulfillment][0] == Time.new.yday
      @data[:tasks][task_name][:day_fulfillment][1] += time
    else
      @data[:tasks][task_name][:day_fulfillment][0] = Time.new.yday
      @data[:tasks][task_name][:day_fulfillment][1] = time
    end

    if @data[:tasks][task_name][:estimate]
      @data[:tasks][task_name][:fulfillment] ||= 0
      @data[:tasks][task_name][:fulfillment] += time.to_f
    end
    
    save(@data)
  end

  def delete_task(task_key)
    @data[:tasks].delete task_key
    save(@data)
  end

  def save_self
    save(@data)
  end
end