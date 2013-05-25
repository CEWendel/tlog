class Tlog::Command::Active < Tlog::Command

	def name 
		"active"
	end 

	def execute(input, output)
		output.line("execute on active command") #change to out
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
				active_logs.push(active_log)
			end
			output.line_yellow("All Time Logs:")
			print_logs(active_logs, output)
		end
	end

	def print_logs(active_logs, output)
		active_logs.each do |active_log|
			if active_log.current
				out_line = active_log.name
				out_line << " (current)"
				output.line_red(out_line);
			else
				output.line(active_log.name)
			end
		end
	end

end