class Tlog::Command::Delete < Tlog::Command

	def name
		"delete"
	end

	def description
		"deletes a time log"
	end

	def execute(input, output)
		raise Tlog::Error::CommandInvalid, "Task does not exist" unless delete(input.args[0])
		output.line("Deleted log '#{input.args[0]}'")
	end

	def options(parser, options)
		parser.banner = "usage: tlog delete <tlog_name>"
	end

	private

	def delete(log_name)
		storage.in_branch do |wd|
			log = storage.require_log(log_name)
			raise Tlog::Error::TimeLogNotFound, "Time log '#{log_name}' does not exist" unless log
			storage.delete_log(log) 
		end
	end

end