class Tlog::Command::Stop < Tlog::Command

	def name 
		"stop"
	end 

	def execute(input, output)
		output.line("execute on stop command") #change to out
		#create_task(input.args[0])
		raise Tlog::Error::CommandInvalid, "Task not in progress" unless stop(input.args[0])
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
		parser.banner = "usage: tlog stop <log_name>"
	end

	private

	def stop(log_name)
		storage.in_branch do |wd|
			log = storage.require_log(log_name)
			#new_entry = Tlog::Task_Entry.new(Time.parse(storage.start_time_string), Time.new, nil, )
			storage.stop_log(log)
		end
	end

	def create_log_entry(name, start_time, log_length, log_description)
		log_storage.initial_log_length = log_length if log_length
		new_entry = Tlog::Task_Entry.new(Time.parse(start_time),Time.new, nil, log_description, cur_entry_owner)
		update_log_storage(log_path(name), new_entry)
		log_storage.create_entry
	end

end