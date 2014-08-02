require 'spec_helper'

describe Parser do
	
	describe "#parse_options" do

		before :each do
			bootstrap
		end

		context "for the print command" do
			it "should print on nil command" do
				ARGV = []
				expect(Parser.parse_options(@config)).to eq({:operation => :print})
			end
		end

		context "for the clear command" do
			it "should set :clear command" do
				ARGV = ["clear"]
				expect(Parser.parse_options(@config)).to eq({:operation => :clear})
			end

			it "should optionally accept a specific alpha task" do
				ARGV = ["clear", "test"]
				expect(Parser.parse_options(@config)).to eq({:operation => :clear, :task => "test"})
			end

			it "should optionally accept a specific numeric task" do
				ARGV = ["clear", "0"]
				expect(Parser.parse_options(@config)).to eq({:operation => :clear, :task => "test"})
			end

			it "should reject an alpha non-task" do
				ARGV = ["clear", "not_a_task"]
				expect {Parser.parse_options(@config)}.to raise_error(ArgumentError)
			end

			it "should reject a numeric non-task" do
				ARGV = ["clear", "4"]
				expect {Parser.parse_options(@config)}.to raise_error(ArgumentError)
			end
		end

		context "for the delete command" do
			it "should set command to delete" do
				ARGV = ["delete", "test"]
				expect(Parser.parse_options(@config)).to eq({:operation => :delete, :task => "test"})
			end

			it "should demand a second argument" do
				ARGV = ["delete"]
				expect {Parser.parse_options(@config)}.to raise_error(ArgumentError)
			end

			it "should reject a non-task alpha value" do
				ARGV = ["delete", "not_a_task"]
				expect {Parser.parse_options(@config)}.to raise_error(ArgumentError)
			end

			it "should reject a out-of-bounds numeric value" do
				ARGV = ["delete", "5"]
				expect {Parser.parse_options(@config)}.to raise_error(ArgumentError)
			end
		end

		context "for the info command" do
			it "should set command as :info" do
				ARGV = ["info"]
				expect(Parser.parse_options(@config)).to eq({:operation => :info})
			end

			it "should also accept a specific task" do
				ARGV = ["info", "test"]
				expect(Parser.parse_options(@config)).to eq({:operation => :info, :task => "test"})
			end

			it "should raise if task doesn't exist" do
				ARGV = ["info", "not_a_task"]
				expect {Parser.parse_options(@config)}.to raise_error(ArgumentError)
			end
		end

		context "for the help command" do
			it "should set command as :help on 'help'" do
				ARGV = ["help"]
				expect(Parser.parse_options(@config)).to eq({:operation => :help})
			end
		end

		context "for the version command" do
			it "should set command as :version on 'version'" do
				ARGV = ["version"]
				expect(Parser.parse_options(@config)).to eq({:operation => :version})
			end
		end

		context "for the switch command" do
			it "should set :switch command" do
				ARGV = ["test"]
				expect(Parser.parse_options(@config)).to eq({:operation => :switch, :task => "test"})
			end

			it "should also accept numeric tasks" do
				ARGV = ["0"]
				expect(Parser.parse_options(@config)).to eq({:operation => :switch, :task => "test"})
			end

			it "should raise if numeric task if out of bounds" do
				ARGV = ["4"]
				expect {Parser.parse_options(@config)}.to raise_error(ArgumentError)
			end

		end

		context "for the new command" do
			EDITOR = 'vim'

			before :each do
				bootstrap
			end

			it "should set :new command" do
				ARGV = ["test2"]
				expect(Parser.parse_options(@config)).to eq({:operation => :new, :task => "test2"})
			end

			it "should accept a time estimate" do
				ARGV = ["test2", "25"]
				expect(Parser.parse_options(@config)).to eq({:operation => :new, :task => "test2", 
					:estimate => 1500})
			end

			it "should reject a second time estimate" do
				ARGV = ["test2", "25", "34"]
				expect {Parser.parse_options(@config)}.to raise_error(ArgumentError)
			end

			# The three tests that include EDITOR flag are commented out because they require
			# manual interactions to run (until I figure out how to circumvent that of course)
			# and are cumbersome to the testing cycle.

			# # Test 1 of EDITOR: save file with text 'test'
			# it "should capture the description from EDITOR flag" do
			# 	ARGV = ["test2", EDITOR]
			# 	expect(Parser.parse_options(@config)).to eq({:operation => :new, :task => "test2", 
			# 		:description => "test", :editor => true})
			# end

			# # Test 2 of EDITOR: just quit vim
			# it "should raise error if we got no description from EDITOR" do
			# 	ARGV = ["test2", EDITOR]
			# 	expect {Parser.parse_options(@config)}.to raise_error(ArgumentError)
			# end

			it "should accept valid days of the week" do
				ARGV = ["test2", "m", "w"]
				expect(Parser.parse_options(@config)).to eq({:operation => :new, :task => "test2", 
					:days => [:monday, :wednesday]})
			end

			# # Test 3 of EDITOR: Save file with text 'test'
			# it "should accept multiple options in arbitrary order" do
			# 	ARGV = ["test2", EDITOR, "m", "25", "f"]
			# 	expect(Parser.parse_options(@config)).to eq({:operation => :new, :task => "test2",
			# 		:days => [:monday, :friday], :estimate => 1500, :description => "test",
			# 		:editor => true})
			# end
		end
	end
end