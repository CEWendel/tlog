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
			input.options[:length],
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

		parser.on("-l", "--length <log_length>") do |length|
      		options[:length] = length
    	end

    	parser.on("-d", "--description <description>") do |description|
    		options[:description] = description
    	end
	end

	private

	def create_entry(log_name, entry_description, log_length)
		storage.in_branch do |wd|
			log_length = ChronicDuration.parse(log_length) if log_length
			puts "log_length is #{log_length}"
			raise Tlog::Error::CommandInvalid, "Must specify log name" unless log_name
			storage.start_log(log_name, entry_description, log_length)
		end
	end
end