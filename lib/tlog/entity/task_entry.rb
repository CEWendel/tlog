# Should be renamed to "Entry"
class Tlog::Task_Entry

	attr_accessor :hex
	attr_accessor :path

	def initialize(path, hex)
		@path = path
		@hex = hex 
	end

	def length
		time_difference if time[:start] && time[:end]
	end

	def create(parent, current)
		FileUtils.mkdir_p(path)
		time_log = current[:start_time].to_s + " " + Time.now.to_s
		write_file(parent_path, parent)
		write_file(time_path, time_log.strip)
		write_file(description_path, current[:description])
		write_file(owner_path, current[:owner])
	end

	def parent_hex
		read_file(parent_path)
	end

	def time
		time_hash = {}
		start_time_string = ""
		end_time_string = ""
		time_contents = read_file(time_path)
		return time_hash unless time_contents
		split_contents = time_contents.split(" ", 6)
		for i in 0..2
			start_time_string += split_contents[i] + " "
		end
		for i in 3..5
			end_time_string += split_contents[i] + " "
		end
		time_hash[:start] = Time.parse(start_time_string)
		time_hash[:end] = Time.parse(end_time_string)
		return time_hash
	end

	def description
		read_file(description_path)
	end

	def owner 
		read_file(owner_path)
	end

	private

	def write_file(path, content)
		File.open(path, 'w'){ |f| f.write(content)}
	end

	def read_file(path)
		if File.exists?(path)
			contents = File.read(path)
			contents.strip
		end
	end

	def time_difference
		time_hash = time
		difference = time_hash[:end] - time_hash[:start]
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