class History < BaseConfig

  def initialize(file_path)
    super(file_path)
  end

  def save_history(task_name, entrance_time, exit_time)
      @data[:tasks][task_name] ||= Array.new
      @data[:tasks][task_name] << [entrance_time, exit_time]
      save(@data)
  end
end