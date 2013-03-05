class Tlog::Command::Log < Tlog::Command

	def name
		"log"
	end

	def execute(input, output)
		output.line("Execute on log command")

		raise Tlog::Error::CommandInvalid, "Logging invalid" unless log(input.args[0], output)

	end

	def options(parser, options)
		parser.banner = "usage: tlog log"
	end

	private

	def log(tlog_name, output)
		entries = @storage.tlog_entries(tlog_name)
		length = @storage.tlog_length(tlog_name)
		output.line("Time entries for tlog: " + tlog_name)
		output.line("Time left: " + length.to_s) if length
		entries.each do |entry|
			out_str = entry.start_time.to_s
			out_str << " " + entry.end_time.to_s
			out_str << " Length: " + entry.length.to_s
			output.line(out_str)
		end
	end
end