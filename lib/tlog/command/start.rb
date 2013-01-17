
class Tlog::Command::Start < Tlog::Command

	def name 
		"start"
	end 

	def execute(input, output)
		output.line("execute on stop command") #change to out
		create_task(input.args[0])
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
	end

	private

	def create_task(task_name)
		raise Tlog::Error::CommandInvalid, "Must specify task name" if !task_name
		task = Tlog::Task.new(task_name, Time.new)
		@storage.create_current(task)
	end
end