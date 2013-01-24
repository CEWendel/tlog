
class Tlog::Task_Entry

	attr_reader :start_time
	attr_reader :end_time
	attr_accessor :hash

	def initialize(start_time, end_time)
		@start_time = start_time
		@end_time = end_time
	end

end