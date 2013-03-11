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
		print_time_left(log_name, log_length, start_time, output)
		display_entries(entries, output)
	end

	def display_all(length_threshold, output)
		storage.all_log_dirs.each do |log_path|
			log_basename = log_path.basename.to_s
			display_log(log_basename, length_threshold, output)
		end
	end

	def display_entries(entries, output)
		entries.each do |entry|
			out_str = ""
			out_str += "#{date_time_format.timestamp entry.start_time}"
			out_str += " -> #{date_time_format.timestamp entry.end_time}"
			out_str += " Length: #{seconds_format.duration entry.length.to_s}"
			output.line(out_str)
		end
	end

	def print_log_name(log_name, output)
		output.line_yellow("Log: #{log_name}")
	end

	def print_time_left(log_name, log_length, current_start_time, output)
		if is_current_log_name?(log_name)
			output.line_red("Time left: #{seconds_format.duration update_log_length(log_length)}")
			formatted_length = seconds_format.duration storage.time_since_start
			output.line("#{date_time_format.timestamp current_start_time} -> \t\t       Length: #{formatted_length}")
		else
			output.line_red("Time left: #{seconds_format.duration log_length}") if log_length
		end
	end

	def length_exceeds_threshold?(log_length, length_threshold)
		if length_threshold and log_length
			length_threshold = ChronicDuration.parse(length_threshold)
			return true if log_length - length_threshold > 0
			false
		else
			false
		end
	end

	def update_log_length(log_length)
		log_length - storage.time_since_start
	end

	def is_current_log_name?(log_name)
		if storage.current_log_name == log_name
			true
		else
			false
		end
	end
end