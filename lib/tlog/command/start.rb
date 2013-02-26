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
		raise Tlog::Error::CommandInvalid, "Task already in progress" unless create_task(input.args[0], input.options[:length])
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
		parser.banner = "usage: tlog start <task_name>"

		parser.on("-l", "--length <task_length>") do |length|
      		options[:length] = length
    	end
	end

	private

	def create_task(task_name, task_length)
		task_length = ChronicDuration.parse(task_length) if task_length
		raise Tlog::Error::CommandInvalid, "Must specify task name" if !task_name
		@storage.update_current(task_name, task_length)
	end
end