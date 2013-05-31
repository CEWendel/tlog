class Tlog::Command::Active < Tlog::Command

	def name 
		"active"
	end 

	def description
		"prints out all active time logs, the time log in-progress if there is one. Or the currently checked-out time log"
	end

	def execute(input, output)
		print_time_entry(output)
	end

	def options(parser, options)
		parser.banner = "usage: tlog active"
	end

	private

	def print_time_entry(output)
		storage.in_branch do |wd|
			all_logs = @storage.all_log_dirs
			active_logs = []
			all_logs.each do |log|
				log_name = log.basename.to_s
				active_log = Tlog::Entity::Active_Log.new(log_name)
				active_log.current = true if storage.current_log_name == log_name
				active_log.checked_out = true if storage.checkout_value == log_name
				active_logs.push(active_log)
			end
			output.line_yellow("All Time Logs:")
			print_logs(active_logs, output)
		end
	end

	def print_logs(active_logs, output)
		active_logs.each do |active_log|
			out_line = active_log.name
			if active_log.current
				out_line << " (in-progress)"
				output.line_red(out_line);
			elsif active_log.checked_out
				out_line << " (checked_out)"
				output.line_blue(out_line)
			else
				output.line(out_line)
			end
		end
	end

end