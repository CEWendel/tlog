
require 'fileutils'

class Tlog::Storage

	attr_accessor :working_dir

	def initialize(working_dir)	
		@working_dir = working_dir #ie /Users/ChrisW/Documents/Ruby/Jeah
	end

	def init_project	
		raise Tlog::Error::CommandInvalid, "Project already initialized" if File.exists?(filename_for_working_dir)
		FileUtils.mkdir_p(tasks_path)
	end

	def create_current(task)
		puts "update_current called, task name is #{task.name}"
		raise Tlog::Error::CommandInvalid, "Task already in progress" if File.exists?(filename_for_current) 
		FileUtils.touch(filename_for_current)
		File.open(filename_for_current, 'w') {|f| f.write(task.name) }
	end

	def current_exists?
		Dir.exists?(filename_for_current)
	end

	def delete_current
		FileUtils.rm(filename_for_current) if File.exists?(filename_for_current)
	end	


	private

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