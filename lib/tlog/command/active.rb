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
			log_active = false
			out_string = ""
			all_logs.each do |log|
				log_name = log.basename.to_s
				if storage.current_log_name == log_name
					log_name << "(active)" 
					log_active = true
				end
				out_string << log_name + "\n"
			end
			out_string.prepend("No time logs active. Existing time logs:" + "\n") unless log_active
			output.line(out_string)
		end
	end

end