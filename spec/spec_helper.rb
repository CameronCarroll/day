require_relative '../lib/day/configuration'
require_relative '../lib/day/parser'

FILE_PATH = 'test_db'
FULL_FILE_PATH = "#{FILE_PATH}.dir"

$VERBOSE = nil

def bootstrap
	@db = YAML::DBM.new(FILE_PATH)
  @db.clear
	@config = Configuration.new(@db)
  bootstrap_task("test")
end

def bootstrap_task(name)
  @config.new_task({:task => name})
  @config.reload
end

def bootstrap_with_context
  bootstrap
  @config.switch_to("test")
  @config.save
end

class String
  def nan?
    self !~ /^\s*[+-]?((\d+_?)*\d+(\.(\d+_?)*\d+)?|\.(\d+_?)*\d+)(\s*|([eE][+-]?(\d+_?)*\d+)\s*)$/
  end

  def number?
    !self.nan?
  end
end