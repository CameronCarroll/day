class BaseConfig

  attr_reader :file_path, :data

  def initialize(file_path)
    @file_path = file_path
    generate unless File.exists? @file_path
    load
  end

  def load
    @data = load_hash_from_yaml
  end

  def save(data)
    save_hash_to_yaml(data)
  end

  private

  def generate
    puts "[Notice:] Couldn't find '#{@file_path}' -- Generating a new one."
    stub = {
      :version => VERSION,
      :tasks => {}
    }
    save_hash_to_yaml(stub)
  end

  def save_hash_to_yaml(hash)
    FileUtils.mkdir_p(File.dirname(@file_path))
    File.new(@file_path, "w") unless File.exist? @file_path
    File.open(@file_path, "w") do |yaml_file|
      yaml_file.write(hash.to_yaml)
    end
  end

  def load_hash_from_yaml
    yaml_data = File.open(@file_path, 'r') { |handle| load = YAML.load(handle) }
    yaml_data = {} unless yaml_data
    return yaml_data
  end
end