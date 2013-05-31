class Tlog::Command::Stop < Tlog::Command

	def name 
		"stop"
	end 

	def description
		"ends a task for a time log"
	end

	def execute(input, output)
		stop(input.args[0])
	end

	def options(parser, options)
		parser.banner = "usage: tlog stop"
	end

	private

	def stop(log_name)
		storage.in_branch do |wd|
			checked_out_log = storage.checkout_value
			raise Tlog::Error::CheckoutInvalid, "No time log is checked out" unless checked_out_log
			log = storage.require_log(checked_out_log)
			raise Tlog::Error::TimeLogNotFound, "Time log '#{log_name}' does not exist" unless log
			current_log_name = storage.current_log_name
			unless current_log_name = storage.current_log_name
				raise Tlog::Error::CommandInvalid, "'#{checked_out_log}' is the active time log" 
			end
			storage.stop_log(log)
		end
	end

end