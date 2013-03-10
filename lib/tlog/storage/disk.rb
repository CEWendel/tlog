require 'fileutils'
require 'securerandom'
require 'pathname'
require 'time'
require 'chronic'
require 'git'

class Tlog::Storage::Disk

	attr_reader :git
	attr_reader :tlog_dir
	attr_reader :tlog_working
	attr_reader :tlog_index
	attr_reader :working_dir
	attr_reader :log_storage

	def initialize(git_dir)	
		@git = Git.open(find_repo(git_dir))
		proj_path = @git.dir.path.downcase.gsub(/[^a-z0-9]+/i, '-')

		@tlog_dir = '~/.tlog'
		@tlog_working = File.expand_path(File.join(@tlog_dir, proj_path, 'working'))
		@tlog_index = File.expand_path(File.join(@tlog_dir, proj_path, 'index'))

		bs = git.lib.branches_all.map{|b| b.first}

		unless(bs.include?('tlog') && File.directory?(@tlog_working))
			init_tlog_branch(bs.include?('tlog'))
		end

		@log_storage = Tlog::Storage::Task_Store.new
	end

	def init_project	
		if !File.exists?(filename_for_working_dir)
			FileUtils.mkdir_p(tasks_path)
			true
		else
			false
		end
	end

	def start_tlog(tlog_name, tlog_length)
		in_branch do |wd|
			if update_current(tlog_name, tlog_length)
				start_task(tlog_name)
				git.add
				git.commit("Started log #{tlog_name}")
				true
			else
				false
			end
		end
	end

	def stop_tlog(tlog_name)
		in_branch do |wd|
			tlog_name = current_task_name unless tlog_name
			if stop_current
				delete_current(tlog_name)
				git.add
				git.commit("Stopped log #{tlog_name}")
				true
			else
				false
			end
		end
	end

	def delete_tlog(tlog_name)
		in_branch do |wd|
			if Dir.exists?(task_path(tlog_name))
				all_task_dirs.each do |tlog_path|
					tlog_basename = tlog_path.basename.to_s
					if tlog_basename == tlog_name
						FileUtils.rm_rf(tlog_path) if tlog_basename == tlog_name
						git.remove(tlog_path)
						git.commit("Deleted log #{tlog_name}")
					end
				end
			else
				false
			end
		end
	end

	def tlog_entries(tlog_name)
		if task_path(tlog_name)
			log_storage.task_path = task_path(tlog_name)
			log_storage.get_tlog_entries
		else
			nil
		end
	end

	def tlog_length(tlog_name)
		if task_path(tlog_name)
			log_storage.task_path = task_path(tlog_name)
			log_storage.get_tlog_length
		else
			nil
		end
	end

	def find_repo(dir)
		full = File.expand_path(dir)
		ENV["GIT_WORKING_DIR"] || loop do
			return full if File.directory?(File.join(full, ".git"))
			raise "No Repo Found" if full == full=File.dirname(full)
		end
	end

	def start_time_string
		current_start_time if File.exists?(current_path)
	end

	def time_since_start
		if File.exists?(current_path)
			difference = Time.now - Time.parse(current_start_time)
			difference.to_i
		else
			nil
		end
	end

	def current_task_name
		File.open(current_path).first.strip if File.exists?(current_path)
	end

	def all_task_dirs
		Pathname.new(tasks_path).children.select { |c| c.directory? }
	end

	private

	# Code from 'ticgit', temporarily switches to tlog branch 
	def in_branch(branch_exists = true)
		unless File.directory?(@tlog_working)
			FileUtils.mkdir_p(@tlog_working)
		end

		old_current = git.lib.branch_current
		begin
			git.lib.change_head_branch('tlog')
			git.with_index(@tlog_index) do 
				git.with_working(@tlog_working) do |wd|
					git.lib.checkout('tlog') if branch_exists
					yield wd
				end
			end
		ensure
			git.lib.change_head_branch(old_current)
		end
	end

	def init_tlog_branch(tlog_branch = false)
		in_branch(tlog_branch) do
			File.open('.hold', 'w+'){|f| f.puts('hold')}
			unless tlog_branch
				git.add
				git.commit('creating the tlog branch')
			end
		end
	end

	def update_current(task_name, tlog_length)
		puts "update_current called, task name is #{task_name}"
		puts "filename for current is #{current_path}"
		if !File.exists?(current_path)
			FileUtils.touch(current_path)
			write_task_to_current(task_name, tlog_length)
			true
		else
			false
		end
	end

	def delete_current(task_name) # Change this method name or add one
		puts "delete_current called, task name is #{task_name}"
		if File.exists?(current_path)
			if current_task_name == task_name
				FileUtils.rm(current_path)
				git.remove(current_path)
			end
		else
			false
		end
	end	

	def write_task_to_current(task_name, task_length)
		content = task_name + "\n" + Time.new.to_s
		content << "\n" + task_length.to_s if task_length
		File.open(current_path, 'w') { |f| f.write(content)}
	end

	def current_exists?
		Dir.exists?(current_path)
	end

	def stop_current
		if File.exists?(current_path)
			stop_task(current_task_name, current_start_time, current_log_length)
			true
		else
			false
		end
	end

	def current_start_time
		contents = File.read(current_path)
		contents.slice! current_task_name
		start_time = contents
		split_contents = contents.split(' ', 4)
		if split_contents.length == 4
			contents.slice! split_contents[3]
			start_time = contents
		end
		start_time
	end

	def current_log_length
		contents = File.read(current_path)
		contents.slice! current_task_name
		split_contents = contents.split(' ', 4)
		if split_contents.length == 4
			task_length = split_contents[3]
		else
			nil
		end
	end

	def stop_task(name, start_time, task_length)
		log_storage.initial_tlog_length = task_length if task_length
		new_entry = Tlog::Task_Entry.new(Time.parse(start_time),Time.new, nil)
		updatelog_storage(task_path(name), new_entry)
		log_storage.create_entry
	end

	def start_task(task_name)
		FileUtils.mkdir_p(task_path(task_name)) unless Dir.exists?(task_path(task_name))
	end

	def updatelog_storage(task_path, task_entry)
		log_storage.task_path = task_path
		log_storage.entry = task_entry
	end

	def task_path(task_name)
		File.join(tasks_path, task_name)
	end

	def tasks_path
		File.expand_path(File.join('tasks'))
	end

	def current_path
		File.expand_path(File.join('current'))
	end

end