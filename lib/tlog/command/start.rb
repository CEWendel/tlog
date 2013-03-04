require "chronic_duration"

class Tlog::Command::Start < Tlog::Command

	def name 
		"start"
	end 

	def execute(input, output)
		output.line("execute on stop command") #change to out

		#def determine_action(input)
   # if input.arguments[0].nil?
    #  :list_postal_addresses
    #elsif input.options.empty?
     # :show_postal_address
    #else
    #  :set_postal_address
    #end
  	#end
		raise Tlog::Error::CommandInvalid, "Task already in progress" unless create_entry(input.args[0], input.options[:length])
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
		parser.banner = "usage: tlog start <tlog_name>"

		parser.on("-l", "--length <tlog_length>") do |length|
      		options[:length] = length
    	end
	end

	private

	def create_entry(tlog_name, tlog_length)
		tlog_length = ChronicDuration.parse(tlog_length) if tlog_length
		raise Tlog::Error::CommandInvalid, "Must specify tlog name" unless tlog_name
		@storage.start_tlog(tlog_name, tlog_length)
	end
end