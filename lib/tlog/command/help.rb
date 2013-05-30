
class Tlog::Command::Help < Tlog::Command

	def name
		"help"
	end

	def description
		"outputs lists of commands and their descriptions"
	end

	def execute(input, output)
		commands = Tlog::Command_Suite.commands
		commands.sort! {|a,b| a.name <=> b.name}
		max_name_length = 0

		commands.each do |command|
			name_length = command.name.length
			max_name_length = name_length if name_length > max_name_length 
		end

		output.line("usage: tlog <command>")
		output.line(nil)

		commands.each do |command|
			line = sprintf("%-#{max_name_length}s  %s", command.name, command.description)
			output.line(line)
		end

		output.line(nil)
		return true
	end

	def options(parser, options)
		parser.banner = "usage: tlog help"
	end

end