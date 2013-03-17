require 'chronic_duration'
require 'time'
class Tlog::Command::Log < Tlog::Command

	def name
		"log"
	end

	def execute(input, output)
		output.line("Execute on log command")

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
		entries = storage.log_entries(log_name)
		log_length = storage.log_length(log_name)
		if storage.start_time_string && is_current_log_name?(log_name)
			start_time = Time.parse(storage.start_time_string)
		end
		return if length_exceeds_threshold?(log_length, length_threshold)
		print_log_name(log_name, output)
		print_header(output)
		print_current(log_name, log_length, start_time, output)
		display_entries(entries, output)
		print_footer(log_name, log_length, output)
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
				out_str = "\t%-4s   %16s  %11s         %s" % [
					date_time_format.timestamp(entry.start_time),
					date_time_format.timestamp(entry.end_time),
					seconds_format.duration(entry.length.to_s),
					entry.description,
				]
				output.line(out_str)
			end
		end
	end

	def print_footer(log_name, log_length, output)
		output.line "-" * 100
		print_total(log_name, output)
		print_time_left(log_name, log_length, output)
	end

	def print_header(output)
		output.line("\tStart               End                    Duration        Description")
	end 

	def print_total(log_name, output)
		#output.line("-") * 52
		output.line("\tTotal%45s " % seconds_format.duration(storage.log_duration(log_name)))
	end

	def print_log_name(log_name, output)
		output.line_yellow("Log: #{log_name}")
	end

	def print_time_left(log_name, log_length, output)
		# should just get storage object...
		if (storage.current_log_name == log_name) && storage.cur_log_length
			log_length = storage.cur_log_length
		end
		log_length = update_log_length(log_length) if storage.time_since_start
		if log_length
			log_length = 0 if log_length < 0
			output.line_red("\tTime left: %39s" % seconds_format.duration(log_length)) if log_length
		end
	end

	# just print out the attributes of goddamn current object
	def print_current(log_name, log_length, current_start_time, output)
		if is_current_log_name?(log_name)
			formatted_length = seconds_format.duration storage.time_since_start
			out_str = out_str = "\t%-4s   %16s   %11s         %s" % [
				date_time_format.timestamp(current_start_time),
				nil,
				formatted_length,
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