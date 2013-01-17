
require "optparse"

class Tlog::Application

	def initialize(input, output)
		@input = input
		@output = output
	end

	def run
		command_name = ""
		outcome = false
		begin
			command_name = @input.args.shift
			command = find(command_name)
			prepare_command(command)
			outcome = run_command(command)
		rescue OptionParser::InvalidOption, OptionParser::MissingArgument
			@output.error($!)
			@output.error(@optparse.to_s)
		rescue Tlog::Error::CommandInvalid
			@output.error(command_name + " syntax invalid: " + $!.message)
			@output.error(@optparse.to_s)
		rescue Tlog::Error::CommandNotFound
			@output.error(command_name +": " + $!.message) # format class?
		rescue
			@output.error($!)
		end
		return outcome
	end

	def all_commands
		commands = [
			Tlog::Command::Test.new,
			Tlog::Command::Init.new,
			Tlog::Command::Start.new,
			Tlog::Command::Stop.new,
		]
		commands.each do |command|
			command.storage = working_dir_storage
		end
		return commands
	end


	private

	def working_dir_storage
		Tlog::Storage.new(Dir.pwd)
	end

	def find(command_name)
		all_commands.select { |command| command.name == command_name }.first
	end

	def prepare_command(command)
		if !command.nil?
			@optparse = OptionParser.new do |parser|
				command.options(parser, @input.options)
			end
			@optparse.parse!(@input.args)
		end
	end

	def run_command(command)
		if !command.nil?
			command.execute(@input, @output)
			true
		else
			raise Tlog::Error::CommandNotFound, "Command not found"
		end
	end

end