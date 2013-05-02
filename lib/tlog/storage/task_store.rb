# Should be renamed to "log_store"
require 'fileutils'
require 'securerandom'
require 'pathname'
require 'time'

class Tlog::Storage::Task_Store

	attr_accessor :entry
	attr_accessor :log_path
	attr_accessor :initial_log_length

	def create_entry
		@entry.hash = generate_random_hex
		FileUtils.mkdir_p(entry_path)
		write_to_entry
		update_head(entry.length)
	end

	def get_tlog_entries
		commands = Array.new
		return commands unless head_hash_value
		if(head_hash_value)
			puts "headhash value not nil"
		else
			puts "nil as fuck"
		end
		hash_value = head_hash_value
		begin 
			@entry = Tlog::Task_Entry.new(nil, nil, hash_value, nil, nil)
			return nil unless update_cur_entry
			commands << @entry
			hash_value = entry_parent_hash
		end until hash_value == "none"
		return commands
	end

	def get_tlog_length
		if File.exists?(head_path)
			content = File.read(head_path)
			split_contents = content.split(' ', 2)
			if split_contents.length == 2
				split_contents[1].to_i
			else
				nil
			end
		else
			nil
		end 
	end

	def update_head(entry_length)
		create_head unless File.exists?(head_path)
		content = entry.hash
		if initial_log_length
			tlog_length = initial_log_length.to_i
		else
			tlog_length = get_tlog_length if get_tlog_length
		end
		if tlog_length
			content += "\n" + lengths_differnce(entry_length, tlog_length)
			File.open(head_path, 'w') { |f| f.write(content) }
		end
	end

	private

	def head_hash_value
		File.open(head_path).first.strip if File.exists?(head_path)
	end

	def update_cur_entry
		if Dir.exists?(entry_path)
			entry.owner = entry_owner
			entry.description = entry_description
			entry.start_time = entry_start_time
			entry.end_time = entry_end_time
			entry.reset_length
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

	def entry_start_time
		time_contents = read_file(entry_time_path)
		start_time = ""
		split_contents = time_contents.split(" ", 6)
		for i in 0..2
			start_time += split_contents[i] + " "
		end
		Time.parse(start_time.strip)
	end

	def entry_end_time
		time_contents = read_file(entry_time_path)
		end_time = ""
		split_contents = time_contents.split(" ", 6)
		for i in 3..5
			end_time += split_contents[i] + " "
		end
		Time.parse(end_time.strip)
	end

	def entry_parent_hash
		read_file(entry_parent_path)
	end

	def entry_description
		read_file(entry_description_path)
	end

	def entry_owner
		read_file(entry_owner_path)
	end

	def read_file(path)
		if File.exists?(path)
			contents = File.read(path)
			contents.strip
		else
			nil
		end
	end

	def write_file(path, content)
		File.open(path, 'w'){ |f| f.write(content)}
	end

	def create_head
		FileUtils.touch(head_path)
	end

	def head_path
		File.join(log_path, "HEAD")
	end

	def write_to_entry
		head_hash_value ? parent_hash = head_hash_value : parent_hash = "none"
		time_log = entry.start_time.to_s + " " + entry.end_time.to_s
		write_file(entry_parent_path, parent_hash)
		write_file(entry_time_path, time_log.strip)
		write_file(entry_description_path, entry.description) if entry.description
		write_file(entry_owner_path, entry.owner) if entry.owner
	end

	def entry_path
		File.join(log_path, entry.hash)
	end

	def entry_parent_path
		File.join(entry_path, 'PARENT')
	end

	def entry_time_path
		File.join(entry_path, 'TIME')
	end

	def entry_description_path
		File.join(entry_path, 'DESCRIPTION')
	end

	def entry_owner_path
		File.join(entry_path, 'OWNER')
	end

	def generate_random_hex
		SecureRandom.hex(13)
	end 
end