
require 'fileutils'

class Tlog::Storage

	attr_reader :working_dir

	def initialize(working_dir)	
		@working_dir = working_dir #ie /Users/ChrisW/Documents/Ruby/Jeah
	end

	def init_project	
		#raise Tlog::Error::CommandInvalid, "Project already initialized" if File.exists?(filename_for_working_dir)
		if !File.exists?(filename_for_working_dir)
			FileUtils.mkdir_p(tasks_path)
		else
			nil
		end
	end

	def update_current(current_task)
		puts "update_current called, task name is #{current_task.name}"
		#raise Tlog::Error::CommandInvalid, "Task already in progress" if File.exists?(filename_for_current) 
		if !File.exists?(filename_for_current)
			FileUtils.touch(filename_for_current)
			File.open(filename_for_current, 'w') {|f| f.write(current_task.name) }
			create_task(current_task)
			true
		else
			nil
		end
	end

	def delete_current(current_task_name)
		puts "delete_current called, task name is #{current_task_name}"
		if File.exists?(filename_for_current)
			# CHECK CONTENTS OF CURRENT FILE
			current_file_content = File.read(filename_for_current)
			FileUtils.rm(filename_for_current) if current_task_name == current_file_content
			#delete_task(current_task_name)
		else
			nil
		end
	end	


	private

	def current_exists?
		Dir.exists?(filename_for_current)
	end

	def create_task(task)
		puts "here2"
		FileUtils.mdkir_p(task_path(task.name)) unless Dir.exists?(task_path(task.name))
	end

	def delete_task(task_name)
		if Dir.exists?(task_path(task_name))
			FileUtils.rmdir(task_path(task_name))
		else
			nil
		end
	end

	def task_path(task_name)
		File.join(tasks_path, task_name)
	end

	def filename_for_working_dir
		File.join(@working_dir, ".tlog")
	end

	def tasks_path
		File.join(filename_for_working_dir, "tasks")
	end

	def filename_for_current
		File.join(filename_for_working_dir, "current")
	end

end