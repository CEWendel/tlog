# Should be renamed to "Entry"
class Tlog::Task_Entry

	attr_accessor :start_time
	attr_accessor :end_time
	attr_accessor :length
	attr_accessor :hash

	def initialize(start_time, end_time, hash)
		@start_time = start_time
		@end_time = end_time
		@hash = hash 
		reset_length
	end

	def reset_length
		@length = time_difference if @start_time && @end_time
	end

	private

	def time_difference
		difference = end_time - start_time
		difference.to_i
	end

end