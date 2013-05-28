
class Tlog::Command::Display < Tlog::Command

	def name
		"display"
	end

	def execute(input, output)
		raise Tlog::Error::CommandInvalid, "Logging invalid" unless display(input.args[0], input.options[:length], output)
	end

	def options(parser, options)
		parser.banner = "usage: tlog log <log_name>"

		parser.on("-l", "--length <length_threshold>") do |length|
			options[:length] = length
		end
	end

	private

	def display(log_name, length_threshold, output)
		storage.in_branch do |wd|
			if log_name
				display_log(log_name, length_threshold, output)
			else
				display_all(length_threshold, output)
			end 
		end
	end

	def display_log(log_name, length_threshold, output)
		log = storage.require_log(log_name)
		log_length = log.goal_length
		entries = log.entries
		if storage.start_time_string && is_current_log_name?(log_name)
			start_time = Time.parse(storage.start_time_string)
		end
		return if length_exceeds_threshold?(log_length, length_threshold)
		print_log_name(log_name, output)
		print_header(output)
		print_current(log_name, log_length, start_time, output)
		display_entries(entries, output) if entries
		print_footer(log, log_length, output)
	end

	def display_all(length_threshold, output)
		storage.all_log_dirs.each do |log_path|
			log_basename = log_path.basename.to_s
			display_log(log_basename, length_threshold, output)
		end
	end

	def display_entries(entries, output)
		if entries.size > 0
			entries.each do |entry|
				out_str = "\t%-4s   %16s  %14s   %14s       %s" % [
					date_time_format.timestamp(entry.time[:start]),
					date_time_format.timestamp(entry.time[:end]),
					seconds_format.duration(entry.length.to_s),
					entry.owner,
					entry.description,
				]
				output.line(out_str)
			end
		end
	end

	def print_footer(log, log_length, output)
		output.line "-" * 100
		print_total(log, output)
		print_time_left(log, output)
	end

	def print_header(output)
		output.line("\tStart               End                    Duration        Owner          Description")
	end 

	def print_total(log, output)
		#output.line("-") * 52
		duration = log.duration
		if storage.current_log_name == log.name
			duration += storage.time_since_start
		end
		output.line("\tTotal%45s " % seconds_format.duration(duration))
	end

	def print_log_name(log_name, output)
		output.line_yellow("Log: #{log_name}")
	end

	def print_time_left(log, output)
		if log.goal
			log_goal = log.goal
			if (storage.current_log_name == log.name)
				current_time = Time.now - storage.cur_start_time
				log_goal -= current_time.to_i
			end
			log_goal = 0 if log_goal < 0
			output.line_red("\tTime left: %39s" % seconds_format.duration(log_goal)) 
		end
	end

	#should be added to entries array, not its own seperate thing
	def print_current(log_name, log_length, current_start_time, output)
		if is_current_log_name?(log_name)
			formatted_length = seconds_format.duration storage.time_since_start
			out_str = out_str = "\t%-4s  %16s   %14s   %14s       %s" % [
				date_time_format.timestamp(current_start_time),
				nil,
				formatted_length,
				storage.cur_entry_owner,
				storage.cur_entry_description, 
			]
			output.line(out_str)
			storage.time_since_start
		end
	end

	def length_exceeds_threshold?(log_length, length_threshold)
		if length_threshold and log_length
			length_threshold = ChronicDuration.parse(length_threshold)
			if log_length - length_threshold > 0
				true
			else
				false
			end
		else
			false
		end
	end

	def update_log_length(log_length)
		log_length - storage.time_since_start if log_length
	end

	def is_current_log_name?(log_name)
		if storage.current_log_name == log_name
			true
		else
			false
		end
	end
end