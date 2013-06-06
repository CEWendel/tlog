
class Tlog::Command::Checkout < Tlog::Command

	def name
		"checkout"
	end

	def description 
		"checkouts a time log in order to start tasks on"
	end

	def execute(input, output)
		raise Tlog::Error::CommandInvalid, "Must specify log name" unless input.args[0]
		checkout(input.args[0])
		output.line("Checked-out log '#{input.args[0]}'");
	end

	def options(parser, options)
		parser.banner = "usage: tlog checkout <log_name>"
	end

	private

	def checkout(log_name)
		storage.in_branch do |wd|
			log = storage.require_log(log_name)
			raise Tlog::Error::TimeLogNotFound, "Time log '#{log_name}' does not exist" unless log
			checked_out_log = storage.checkout_value
			if checked_out_log == log.name
				raise Tlog::Error::CommandInvalid, "Time log '#{log_name}' is currently checked out " 
			end
			storage.checkout_log(log)
		end
	end

end