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
        task_object = Task.new(task.first, task[1][:days], task[1][:commitment], task[1][:fulfillment])
        @tasks << task_object
      end
    end
  end

  def save_task(task, valid_days, time_commitment, fulfillment)
    puts "Creating new task: " + task
    @data[:tasks][task] = {:days => valid_days, :commitment => time_commitment, :fulfillment => fulfillment}
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
    @data[:tasks][task_name][:fulfillment] ||= 0
    @data[:tasks][task_name][:fulfillment] += time.to_f
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