
class Tlog::Task
	
	attr_reader :start_time
	attr_reader :name
	attr_accessor :end_time
	attr_accessor :hash

	def initialize(task, task_path)
		@name = task_name
		@start_time = start_time
		@end_time = end_time
	end

end