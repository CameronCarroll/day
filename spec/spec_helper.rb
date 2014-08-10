require_relative '../lib/configuration'
require_relative '../lib/parser'

FILE_PATH = 'test_db'
FULL_FILE_PATH = "#{FILE_PATH}.db"

$VERBOSE = nil

def bootstrap
	FileUtils.rm FULL_FILE_PATH if File.exist? FULL_FILE_PATH
	@db = YAML::DBM.new(FILE_PATH)
	@config = Configuration.new(@db)
  bootstrap_task("test")
end

def bootstrap_task(name)
  @config.new_task({:task => name})
  @config.reload
end

class String
  def nan?
    self !~ /^\s*[+-]?((\d+_?)*\d+(\.(\d+_?)*\d+)?|\.(\d+_?)*\d+)(\s*|([eE][+-]?(\d+_?)*\d+)\s*)$/
  end

  def number?
    !self.nan?
  end
end