
class Tlog::Task
	
	attr_reader :start_time
	attr_reader :name
	attr_accessor :hash
	
	def initialize(task_name, start_time)
		@start_time = start_time
		@name = task_name
	end

end