require "chronic_duration"

class Tlog::Command::Start < Tlog::Command

	def name 
		"start"
	end 

	def execute(input, output)
		output.line("execute on start command") #change to out

		#def determine_action(input)
   # if input.arguments[0].nil?
    #  :list_postal_addresses
    #elsif input.options.empty?
     # :show_postal_address
    #else
    #  :set_postal_address
    #end
  	#end
		raise Tlog::Error::CommandInvalid, "Log already in progress" unless create_entry(
			input.args[0], 
			input.options[:description],
		)
		#if input.args[0].nil?
			# no task name given
			#@storage.create_current
		#	create_task()
		#elsif input.args[1].nil?
		#	arg1 = input.args.shift
			# task name given
			#@storage.create_current(arg1)
		#	create_task(arg1)
		#else
		#	arg1 = input.args.shift
		#	arg2 = input.args.shift
			# invalid, can't have 2 
		#end
	end

	def options(parser, options)
		parser.banner = "usage: tlog start <log_name>"

    	parser.on("-d", "--description <description>") do |description|
    		options[:description] = description
    	end
	end

	private

	def create_entry(log_name, entry_description)
		storage.in_branch do |wd|
			log = storage.require_log(log_name)
			raise Tlog::Error::CommandInvalid, "Time log '#{log_name}' does not exist" unless log
			current_owner = storage.cur_entry_owner
			new_entry = Tlog::Task_Entry.new(Time.now, nil, nil, entry_description, current_owner)
			#log_length = ChronicDuration.parse(log_length) if log_length
			raise Tlog::Error::CommandInvalid, "Must specify log name" unless log_name
			storage.start_log(log, entry_description)
		end
	end
end