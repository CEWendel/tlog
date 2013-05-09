# Should be renamed to "Entry"
class Tlog::Task_Entry

	attr_accessor :start_time
	attr_accessor :end_time
	attr_accessor :length
	attr_accessor :hex
	attr_accessor :description
	attr_accessor :owner
	attr_accessor :path

	def initialize(start_time, end_time, hex, description, owner)
		@start_time = start_time
		@end_time = end_time
		@hex = hex 
		@description = description
		@owner = owner
		reset_length
	end

	def reset_length
		@length = time_difference if @start_time && @end_time
	end

	def create(parent)
		FileUtils.mkdir_p(path)
		time_log = @start_time.to_s + " " + @end_time.to_s
		write_file(parent_path, parent)
		write_file(time_path, time_log.strip)
		write_file(description_path, @description)
		write_file(owner_path, @owner)
	end

	private

	def write_file(path, content)
		File.open(path, 'w'){ |f| f.write(content)}
	end

	def time_difference
		difference = end_time - start_time
		difference.to_i
	end

	def parent_path
		File.join(@path, 'PARENT')
	end

	def time_path
		File.join(@path, 'TIME')
	end

	def description_path
		File.join(@path, 'DESCRIPTION')
	end

	def owner_path
		File.join(@path, 'OWNER')
	end

end