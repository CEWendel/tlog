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

	def print_tlog
		hash_value = get_hash_value
		entry = Tlog::Task_Entry.new(nil, nil, hash_value)
		update_cur_entry(cur_entry)
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
		if split_contents.length == 2
			split_contents[1].to_i
		else
			nil
		end
	end

	def get_hash_value
		File.open(head_path).first.strip
	end

	def update_cur_entry(entry)
		if File.exists?(task_entry_path)
			i = 1
			start_time = ""
			end_time = ""
			contents = File.read(task_entry_path)
			split_contents = contents.split(' ',7)
			contents.slice! split_contents[0]
			until i > 7
				if i < 4
					start_time << split_contents[i] 
				else
					end_time << split_contents[i]
				end
			end
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
		File.open(path, 'w'){ |f| f.write(content) }
	end

	def task_entry_path
		File.join(@task_path, @entry.hash)
	end

	def generate_random_hex
		SecureRandom.hex(13)
	end 
end