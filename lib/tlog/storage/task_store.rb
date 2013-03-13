# Should be renamed to "log_store"
require 'fileutils'
require 'securerandom'
require 'time'

class Tlog::Storage::Task_Store

	attr_accessor :entry
	attr_accessor :log_path
	attr_accessor :initial_log_length

	def create_entry
		@entry.hash = generate_random_hex
		FileUtils.touch(task_entry_path)
		write_to_entry(task_entry_path)
		update_head(entry.length)
	end

	def get_tlog_entries
		commands = Array.new
		return commands unless head_hash_value
		hash_value = head_hash_value
		begin 
			@entry = Tlog::Task_Entry.new(nil, nil, hash_value)
			return nil unless update_cur_entry
			commands << @entry
			hash_value = entry_hash_value
		end until hash_value == "none"
		return commands
	end

	def get_tlog_length
		if File.exists?(head_path)
			content = File.read(head_path)
			split_contents = content.split(' ', 2)
			if split_contents.length == 3
				split_contents[2].to_i
			else
				nil
			end
		else
			nil
		end 
	end

	private

	def previous_entry
		if File.exists?(head_path)
			previous_hash = File.read(head_path)
		else
			nil
		end
	end

	def head_hash_value
		File.open(head_path).first.strip if File.exists?(head_path)
	end

	def entry_hash_value
		File.open(task_entry_path).first.strip
	end

	def update_cur_entry
		if File.exists?(task_entry_path)
			start_time = ""
			end_time = ""
			contents = File.read(task_entry_path)
			split_contents = contents.split(' ',7)
			contents.slice! split_contents[0]
			for i in 1..6
				if i < 4
					start_time << split_contents[i] + " "
				else
					end_time << split_contents[i] + " "
				end
			end
			@entry.start_time = Time.parse(start_time)
			@entry.end_time = Time.parse(end_time)
			@entry.reset_length
			true
		else
			false
		end
	end

	def lengths_differnce(entry_length, tlog_length)
		new_tlog_length = 0 
		if (tlog_length - entry_length) > 0
			new_tlog_length = tlog_length - entry_length
		end
		new_tlog_length.to_s
	end

	def update_head(entry_length)
		create_head unless File.exists?(head_path)
		content = @entry.hash
		if initial_log_length
			tlog_length = initial_log_length.to_i
		else
			tlog_length = get_tlog_length if get_tlog_length
		end
		content += "\n" + lengths_differnce(entry_length, tlog_length) if tlog_length
		File.open(head_path, 'w') { |f| f.write(content) }
	end

	def create_head
		FileUtils.touch(head_path)
	end

	def head_path
		File.join(log_path, "HEAD")
	end

	def write_to_entry(path)
		previous_entry ? content = previous_entry : content = "none"
		time_log = @entry.start_time.to_s + " " + @entry.end_time.to_s
		content += "\n" + time_log
		File.open(path, 'w'){ |f| f.write(content) }
	end

	def task_entry_path
		File.join(log_path, entry.hash)
	end

	def generate_random_hex
		SecureRandom.hex(13)
	end 
end