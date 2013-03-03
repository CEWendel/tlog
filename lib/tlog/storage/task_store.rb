require 'fileutils'
require 'securerandom'

class Tlog::Storage::Task_Store

	attr_accessor :entry
	attr_accessor :task_path
	attr_accessor :initial_tlog_length

	#def initialize(task, path)
	#	@task = task
	#	@task_path = path
	#end

	
	def create_entry
		puts "Create entry called"
		puts "Entry length is #{@entry.length}"
		puts "Difference is #{@entry.end_time - @entry.start_time}"
		@entry.hash = generate_random_hex
		FileUtils.touch(task_entry_path)
		write_to_entry(task_entry_path)
		update_head(@entry.length)
	end

	private

	def previous_entry
		if File.exists?(head_path)
			previous_hash = File.read(head_path)
		else
			nil
		end
	end

	def get_tlog_length
		content = File.read(head_path)
		split_contents = content.split(' ', 2)
		puts "split_contents are #{split_contents}"
		if split_contents.length == 2
			split_contents[1].to_i
		else
			nil
		end
	end

	def update_tlog_length(entry_length, tlog_length)
		new_tlog_length = 0 
		if (tlog_length - entry_length) > 0
			new_tlog_length = tlog_length - entry_length
		end
		new_tlog_length.to_s
	end

	def update_head(entry_length)
		create_head unless File.exists?(head_path)
		content = @entry.hash
		if initial_tlog_length
			content += "\n" + initial_tlog_length if initial_tlog_length
		else
			if get_tlog_length
				# Update HEAD file with new time log length 
				content += "\n" + update_tlog_length(entry_length, get_tlog_length)
			end
		end 
		File.open(head_path, 'w') { |f| f.write(content) }
	end

	def create_head
		FileUtils.touch(head_path)
	end

	def head_path
		File.join(@task_path, "HEAD")
	end

	def write_to_entry(path)
		previous_entry ? content = previous_entry : content = "none"
		time_log = @entry.start_time.to_s + " " + @entry.end_time.to_s
		content += "\n" + time_log
		#content += "\n" + @entry.length.to_s
		File.open(path, 'w'){ |f| f.write(content) }
	end

	def task_entry_path
		File.join(@task_path, @entry.hash)
	end

	def generate_random_hex
		SecureRandom.hex(13)
	end 
end