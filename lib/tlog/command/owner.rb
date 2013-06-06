
class Tlog::Command::Owner < Tlog::Command

	def name 
		"owner"
	end 

	def description
		"changes the owner of the checked-out time log"
	end

	def execute(input, output)
		new_owner = input.args[0]
		updated_log = change_owner(new_owner)
		output.line("Changed owner of '#{updated_log.name}' to #{new_owner}")
	end

	def options(parser, options)
		parser.banner = "usage: tlog owner <new_owner>"
	end

	private

	def change_owner(new_owner)
		storage.in_branch do |wd|
			checked_out_log = storage.checkout_value
			raise Tlog::Error::CheckoutInvalid, "No time log is checked out" unless checked_out_log
			log = storage.require_log(checked_out_log)
			raise Tlog::Error::TimeLogNotFound, "Time log '#{checked_out_log}' does not exist" unless log
			storage.change_log_owner(log, new_owner)
			log
		end
	end
end