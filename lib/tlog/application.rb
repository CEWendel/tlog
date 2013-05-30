
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
		rescue Tlog::Error::CommandNotFound, OptionParser::MissingArgument
			@output.error($!)
			@output.error(@optparse.to_s)
		rescue
			@output.error($!)
		end
		return outcome
	end

	private

	def find(command_name)
		commands = Tlog::Command_Suite.commands
		command = nil
		commands.each do |cmd|
			return cmd if cmd.name == command_name
		end
		command
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
			raise Tlog::Error::CommandNotFound, "Command not found, use 'tlog help' for list of commands"
		end
	end

end