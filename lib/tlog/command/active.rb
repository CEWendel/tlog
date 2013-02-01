class Tlog::Command::Active < Tlog::Command

	def name 
		"active"
	end 

	def execute(input, output)
		output.line("execute on active command") #change to out
		#create_task(input.args[0])
		#if input.args[0].nil? raise Tlog::Error::CommandInvalid, "Invalid command input"
		raise Tlog::Error::CommandInvalid, "Task not in progress" unless show_active_task
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
		parser.banner = "usage: tlog active"
	end

	private

	def show_active_task
		@storage.show_active
		#@storage.delete_current(task_name)
	end

end