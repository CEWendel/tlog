
class Tlog::Command::Start < Tlog::Command

	def name 
		"start"
	end 

	def description
		"starts a new task for a time log"
	end

	def execute(input, output)
		updated_log = start(input.options[:description])
		output.line("Started '#{log.name}'")
	end

	def options(parser, options)
		parser.banner = "usage: tlog start"

    	parser.on("-d", "--description <description>") do |description|
    		options[:description] = description
    	end
	end

	private

	def start(entry_description)
		storage.in_branch do |wd|
			checked_out_log = storage.checkout_value
			raise Tlog::Error::CheckoutInvalid, "No time log is checked out" unless checked_out_log
			log = storage.require_log(checked_out_log)
			raise Tlog::Error::TimeLogNotFound, "Time log '#{checked_out_log}' does not exist" unless log
			unless storage.start_log(log, entry_description)
				raise Tlog::Error::CommandInvalid, "Time log '#{checked_out_log}' is already in progress"
			end
			log
		end
	end
end