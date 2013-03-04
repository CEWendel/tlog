
class Tlog::Task_Entry

	attr_accessor :start_time
	attr_accessor :end_time
	attr_accessor :length
	attr_accessor :hash

	def initialize(start_time = "", end_time = "", hash = "")
		@start_time = start_time
		@end_time = end_time
		@length = time_difference
		@hash = hash 
	end

	private

	def time_difference
		difference = end_time - start_time
		difference.to_i
	end

end