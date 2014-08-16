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
			expect(@config.data['tasks'].class).to be(Hash)
		end
	end

	describe "#new_task" do
		before :each do
			bootstrap
		end

		it "adds a task to the database" do
			test_name = 'test_task_name'
			opts = {:task => test_name, :description => 'some description'}
			expect(@config.data['tasks'][test_name]).to be(nil)
			@config.new_task(opts)
			@config.reload
			expect(@config.data['tasks'][test_name]).to be_truthy
		end
	end

	describe "#switch_to" do
		before :each do
			bootstrap
		end

		it "should enter a new context (no current)" do
			binding.pry
			expect(@config.data['context']).to eq(nil)
			@config.switch_to("test")
			expect(@config.data['context']).to eq("test")
		end

		it "should enter a new context (given a current one)" do
			bootstrap_task("test2")
			@config.switch_to("test")
			expect(@config.data['context']).to eq("test")
			@config.switch_to("test2")
			expect(@config.data['context']).to eq("test2")
		end
	end

	describe "#delete" do
		before :each do
			bootstrap
		end

		it "should remove a task from data" do
			expect(@config.data['tasks']['test']).to be_truthy
			@config.delete("test")
			expect(@config.data['tasks']['test']).not_to be_truthy
		end
	end

	describe "#clear_context" do
		before :each do
			bootstrap
		end

		it "should clear context given a current one" do
			@config.switch_to("test")
			expect(@config.data['context']).to eq("test")
			@config.reload
			@config.clear_context
			expect(@config.data['context']).to eq(nil)
		end

		it "should add time to the fulfillment" do
			@config.switch_to("test")
			@config.reload
			@config.clear_context
			expect(@config.data['tasks']['test']['fulfillment']).to be_truthy
		end
	end

	describe "#clear_fulfillment" do
		before :each do
			bootstrap
		end

		it "should clear fulfillment for a specified task" do
			@config.switch_to("test")
			@config.reload
			@config.clear_context
			@config.reload
			expect(@config.data['tasks']['test']['fulfillment']).to be_truthy
			@config.clear_fulfillment("test")
			@config.reload
			expect(@config.data['tasks']['test']['fulfillment']).not_to be_truthy
		end

		it "should clear fulfillment for all tasks otherwise" do
			@config.switch_to("test")
			@config.reload
			@config.clear_context
			@config.reload
			expect(@config.data['tasks']['test']['fulfillment']).to be_truthy
			@config.clear_fulfillment(nil)
			@config.reload
			expect(@config.data['tasks']['test']['fulfillment']).not_to be_truthy
		end
	end

	describe "#lookup_task" do
		before :each do
			bootstrap
		end

		it "should return a task name given a corresponding name" do
			input = "test"
			expect(@config.lookup_task(input)).to eq(input)
		end

		it "should return a task name given a corresponding index" do
			input = "0"
			expected = "test"
			expect(@config.lookup_task(input)).to eq(expected)
		end

		it "should return nil given a non-task name" do
			input = "non-task"
			expect(@config.lookup_task(input)).to eq(nil)
		end

		it "should return nil given an out-of-bound index" do
			input = "1"
			expect(@config.lookup_task(input)).to eq(nil)
		end
	end

end