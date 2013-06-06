
class Tlog::Command::Points < Tlog::Command

	def name 
		"points"
	end 

	def description
		"changes the point value of the checked-out time log"
	end

	def execute(input, output)
		new_points_value = input.args[0]
		update_log = change_state(new_points_value)
		output.line("Changed points of '#{updated_log.name}' to #{new_points_value}")
	end

	def options(parser, options)
		parser.banner = "usage: tlog points <new_points_value>"
	end

	private

	def change_state(points)
		storage.in_branch do |wd|
			checked_out_log = storage.checkout_value
			raise Tlog::Error::CheckoutInvalid, "No time log is checked out" unless checked_out_log
			log = storage.require_log(checked_out_log)
			raise Tlog::Error::TimeLogNotFound, "Time log '#{checked_out_log}' does not exist" unless log
			storage.change_log_points(log, points)
			log
		end
	end
end