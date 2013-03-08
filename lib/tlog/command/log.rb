require 'chronic_duration'
require 'time'
class Tlog::Command::Log < Tlog::Command

	def name
		"log"
	end

	def execute(input, output)
		output.line("Execute on log command")

		raise Tlog::Error::CommandInvalid, "Logging invalid" unless log(input.args[0], input.options[:length], output)
	end

	def options(parser, options)
		parser.banner = "usage: tlog log <tlog_name>"

		parser.on("-l", "--length <length_threshold>") do |length|
			options[:length] = length
		end
	end

	private

	def log(tlog_name, length_threshold, output)
		if tlog_name
			log_tlog(tlog_name, length_threshold, output)
		else
			log_all(length_threshold, output)
		end 
	end

	def log_tlog(tlog_name, length_threshold, output)
		entries = @storage.tlog_entries(tlog_name)
		tlog_length = @storage.tlog_length(tlog_name)
		length_threshold = ChronicDuration.parse(length_threshold) if length_threshold
		if length_threshold and tlog_length
			return if (tlog_length - length_threshold) > 0
		end
		output.line("Time entries for tlog: " + tlog_name)
		output.line("Time left: #{@seconds_format.duration tlog_length}") if tlog_length
		entries.each do |entry|
			out_str = ""
			out_str += "#{@date_time_format.timestamp entry.start_time}"
			out_str += " -> #{@date_time_format.timestamp entry.end_time}"
			out_str += " Length: #{@seconds_format.duration entry.length.to_s}"
			output.line(out_str)
		end
	end

	def log_all(length_threshold, output)
		@storage.all_task_dirs.each do |tlog_path|
			tlog_basename = tlog_path.basename.to_s
			log_tlog(tlog_basename, length_threshold, output)
		end
	end
end