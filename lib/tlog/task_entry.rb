
class Tlog::Task_Entry

	attr_reader :start_time
	attr_reader :end_time
	attr_accessor :length
	attr_accessor :hash

	def initialize(start_time, end_time)
		@start_time = start_time
		@end_time = end_time
		@length = time_difference 
	end

	private

	def time_difference
		difference = end_time - start_time
		difference.to_i
	end

end