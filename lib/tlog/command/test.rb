
class Tlog::Command::Test < Tlog::Command

	def name
		"test"
	end

	def execute(input,output)
		output.line("execute on test called")
		if input.args[0].nil?
			output.line("args at 0 was nil")
		elsif input.args[1].nil?
			arg1 = input.args.shift
			output.line("arg at 0 was #{arg1}")
		else
			arg1 = input.args.shift
			arg2 = input.args.shift
			output.line("arg at 0 was #{arg1}")
			output.line("arg at 1 was #{arg2}")	
			raise Tlog::Error::CommandInvalid, "Command invalid"	
		end
	end

	def options(parser, options)
		parser.banner = "usage: tlog test <project>"
	end

	private



end