require 'spec_helper'
require 'fileutils'
describe Configuration do

	describe "#initialize" do
		before :each do
			bootstrap
		end

		it "accepts a file path and creates a DB file." do
			expect(File.exists?(FULL_FILE_PATH)).to be(true)
		end

		it "bootstraps the DB" do
			expect(@config.tasks.class).to be(Hash)
		end
	end

	describe "#save_task" do
		before :each do
			bootstrap
		end

		it "adds a task to the database" do
			test_name = 'test_task_name'
			test_description = 'some description'
			valid_days = nil
			estimate = nil
			expect(@config.tasks[test_name]).to be(nil)
			@config.save_task(test_name, test_description, valid_days, estimate)
			@config.reload
			expect(@config.tasks[test_name].name).to eq(test_name)
		end
	end

end