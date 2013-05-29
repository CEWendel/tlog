
class Tlog::Command::Start < Tlog::Command

	def name 
		"start"
	end 

	def description
		"starts a new task for a time log"
	end

	def execute(input, output)
		raise Tlog::Error::CommandInvalid, "Must specify log name" unless input.args[0]
		start(input.args[0], input.options[:description])
	end

	def options(parser, options)
		parser.banner = "usage: tlog start <log_name>"

    	parser.on("-d", "--description <description>") do |description|
    		options[:description] = description
    	end
	end

	private

	def start(log_name, entry_description)
		storage.in_branch do |wd|
			log = storage.require_log(log_name)
			raise Tlog::Error::CommandNotFound, "Time log '#{log_name}' does not exist" unless log
			current_owner = storage.cur_entry_owner
			storage.start_log(log, entry_description)
		end
	end
end