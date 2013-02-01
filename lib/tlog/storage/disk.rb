
require 'fileutils'
require 'securerandom'
require 'pathname'

class Tlog::Storage::Disk

	attr_reader :working_dir
	attr_reader :task_storage

	def initialize(working_dir)	
		@working_dir = working_dir #ie /Users/ChrisW/Documents/Ruby/Jeah
		@task_storage = Tlog::Storage::Task_Store.new
	end

	def init_project	
		#raise Tlog::Error::CommandInvalid, "Project already initialized" if File.exists?(filename_for_working_dir)
		if !File.exists?(filename_for_working_dir)
			FileUtils.mkdir_p(tasks_path)
			true
		else
			false
		end
	end

	def update_current(task_name)
		puts "update_current called, task name is #{task_name}"
		#raise Tlog::Error::CommandInvalid, "Task already in progress" if File.exists?(filename_for_current) 
		if !File.exists?(filename_for_current)
			FileUtils.touch(filename_for_current)
			write_task_to_current(task_name)
			start_task(task_name)
			true
		else
			false
		end
	end

	def delete_current(task_name) # Change this method name or add one
		puts "delete_current called, task name is #{task_name}"
		if File.exists?(filename_for_current)
			#create_finished_task(task_name)
			parse_current
			FileUtils.rm(filename_for_current) if current_task_name == task_name
		else
			false
		end
	end	

	def show_active
		active_tasks = all_task_dirs
		active_tasks.each do |task|
			task_name = task.basename.to_s
			task_name << "(active)" if current_task_name == task_name
			puts "#{task_name}"
		end
	end

	private

	def all_task_dirs
		Pathname.new(tasks_path).children.select { |c| c.directory? }
	end

	def write_task_to_current(task_name)
		content = task_name + "\n" + Time.new.to_s
		File.open(filename_for_current, 'w') { |f| f.write(content)}
	end

	def current_exists?
		Dir.exists?(filename_for_current)
	end

	def current_task_name
		File.open(filename_for_current).first.strip unless !File.exists?(filename_for_current)
	end

	def parse_current
		contents = File.read(filename_for_current)
		task_name = contents.split(' ', 2)[0]
		contents.slice! task_name
		start_time = contents
		stop_task(task_name, start_time)
	end

	def stop_task(name, start_time)
		new_entry = Tlog::Task_Entry.new(start_time, Time.new.to_s)
		update_task_storage(task_path(name), new_entry)
		@task_storage.create_entry
	end

	def start_task(task_name)
		FileUtils.mkdir_p(task_path(task_name)) unless Dir.exists?(task_path(task_name))
	end

	def update_task_storage(task_path, task_entry)
		@task_storage.task_path = task_path
		@task_storage.entry = task_entry
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