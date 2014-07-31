require_relative '../lib/configuration'
require_relative '../lib/parser'

FILE_PATH = 'test_db'
FULL_FILE_PATH = "#{FILE_PATH}.db"

def bootstrap
	FileUtils.rm FULL_FILE_PATH if File.exist? FULL_FILE_PATH
	@db = YAML::DBM.new(FILE_PATH)
	@config = Configuration.new(@db)
	@config.save_task("test", nil, nil, nil)
	@config.reload
end