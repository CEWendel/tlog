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
	attr_reader :task_storage

	def initialize(git_dir)	
		@git = Git.open(find_repo(git_dir))
		proj_path = @git.dir.path.downcase.gsub(/[^a-z0-9]+/i, '-')
		#def self.clean_string(string)
      	#string.downcase.gsub(/[^a-z0-9]+/i, '-')
    	#end
		@tlog_dir = '~/.tlog'
		@tlog_working = File.expand_path(File.join(@tlog_dir, proj_path, 'working'))
		@tlog_index = File.expand_path(File.join(@tlog_dir, proj_path, 'index'))

		bs = git.lib.branches_all.map{|b| b.first}

		unless(bs.include?('tlog') && File.directory?(@tlog_working))
			init_tlog_branch(bs.include?('tlog'))
		end

		@task_storage = Tlog::Storage::Task_Store.new
	end

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
		tlog_name = current_task_name unless tlog_name
		in_branch do |wd|
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
		if Dir.exists?(task_path(tlog_name))
			all_task_dirs.each do |tlog_path|
				tlog_basename = tlog_path.basename.to_s
				FileUtils.rm_rf(tlog_path) if tlog_basename == tlog_name
			end
		else
			false
		end
	end

	def tlog_entries(tlog_name)
		if task_path(tlog_name)
			@task_storage.task_path = task_path(tlog_name)
			@task_storage.get_tlog_entries
		else
			nil
		end
	end

	def tlog_length(tlog_name)
		if task_path(tlog_name)
			@task_storage.task_path = task_path(tlog_name)
			@task_storage.get_tlog_length
		else
			nil
		end
	end

	def find_repo(dir)
		full = File.expand_path(dir)
		ENV["GIT_WORKING_DIR"] || loop do
			if File.directory?(File.join(full, ".git"))
				puts "repo is #{full}"
				return full
			end
			raise "No Repo Found" if full == full=File.dirname(full)
		end
	end

	def start_time_string
		current_start_time if File.exists?(filename_for_current)
	end

	def time_since_start
		if File.exists?(filename_for_current)
			difference = Time.now - Time.parse(current_start_time)
			difference.to_i
		else
			nil
		end
	end

	def current_task_name
		File.open(filename_for_current).first.strip if File.exists?(filename_for_current)
	end

	def all_task_dirs
		Pathname.new(tasks_path).children.select { |c| c.directory? }
	end

	private

	def update_current(task_name, tlog_length)
		puts "update_current called, task name is #{task_name}"
		puts "filename for current is #{filename_for_current}"
		if !File.exists?(filename_for_current)
			FileUtils.touch(filename_for_current)
			write_task_to_current(task_name, tlog_length)
			true
		else
			false
		end
	end

	def delete_current(task_name) # Change this method name or add one
		puts "delete_current called, task name is #{task_name}"
		if File.exists?(filename_for_current)
			FileUtils.rm(filename_for_current) if current_task_name == task_name
		else
			false
		end
	end	

	def write_task_to_current(task_name, task_length)
		content = task_name + "\n" + Time.new.to_s
		content << "\n" + task_length.to_s if task_length
		File.open(filename_for_current, 'w') { |f| f.write(content)}
	end

	def current_exists?
		Dir.exists?(filename_for_current)
	end

	def stop_current
		if File.exists?(filename_for_current)
			stop_task(current_task_name, current_start_time, current_log_length)
			true
		else
			false
		end
	end

	def current_start_time
		contents = File.read(filename_for_current)
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
		contents = File.read(filename_for_current)
		contents.slice! current_task_name
		split_contents = contents.split(' ', 4)
		if split_contents.length == 4
			task_length = split_contents[3]
		else
			nil
		end
	end

	def stop_task(name, start_time, task_length)
		@task_storage.initial_tlog_length = task_length if task_length
		new_entry = Tlog::Task_Entry.new(Time.parse(start_time),Time.new, nil)
		puts "here"
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

	def task_path(task_name)
		File.join(tasks_path, task_name)
	end

	def tasks_path
		File.expand_path(File.join('tasks'))
	end

	def filename_for_current
		File.expand_path(File.join('current'))
	end

end