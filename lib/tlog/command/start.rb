
class Tlog::Command::Start < Tlog::Command

	def name 
		"start"
	end 

	def description
		"starts a new task for a time log"
	end

	def execute(input, output)
		start(input.args[0], input.options[:description])
	end

	def options(parser, options)
		parser.banner = "usage: tlog start"

    	parser.on("-d", "--description <description>") do |description|
    		options[:description] = description
    	end
	end

	private

	def start(log_name, entry_description)
		storage.in_branch do |wd|
			checked_out_log = storage.checkout_value
			raise Tlog::Error::CheckoutInvalid, "No time log is checked out" unless checked_out_log
			log = storage.require_log(checked_out_log)
			raise Tlog::Error::CommandNotFound, "Time log '#{log_name}' does not exist" unless log
			storage.start_log(log, entry_description)
		end
	end
end