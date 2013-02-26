require 'fileutils'
require 'securerandom'

class Tlog::Storage::Task_Store

	attr_accessor :entry
	attr_accessor :task_path

	#def initialize(task, path)
	#	@task = task
	#	@task_path = path
	#end

	
	def create_entry
		puts "Create entry called"
		@entry.hash = generate_random_hex
		FileUtils.touch(task_entry_path)
		write_to_entry(task_entry_path)
		update_head
	end

	private

	def previous_entry
		if File.exists?(head_path)
			previous_hash = File.read(head_path)
		else
			nil
		end
	end

	def update_head
		create_head unless File.exists?(head_path)
		content = @entry.hash
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
		content = content + "\n" + time_log
		File.open(path, 'w'){ |f| f.write(content) }
	end

	def task_entry_path
		File.join(@task_path, @entry.hash)
	end

	def generate_random_hex
		SecureRandom.hex(13)
	end 
end