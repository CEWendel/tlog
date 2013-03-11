class Tlog::Command::Delete < Tlog::Command

	def name
		"delete"
	end

	def execute(input, output)
		output.line("execute on delete command")

		raise Tlog::Error::CommandInvalid, "Task does not exist" unless delete(input.args[0])
	end

	def options(parser, options)
		parser.banner = "usage: tlog delete <tlog_name>"
	end

	private

	def delete(tlog_name)
		storage.in_branch do |wd|
			storage.delete_log(tlog_name)
		end
	end

end