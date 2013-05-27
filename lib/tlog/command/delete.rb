class Tlog::Command::Delete < Tlog::Command

	def name
		"delete"
	end

	def execute(input, output)
		raise Tlog::Error::CommandInvalid, "Task does not exist" unless delete(input.args[0])
	end

	def options(parser, options)
		parser.banner = "usage: tlog delete <tlog_name>"
	end

	private

	def delete(log_name)
		storage.in_branch do |wd|
			log = storage.require_log(log_name)
			storage.delete_log(log) if log
		end
	end

end