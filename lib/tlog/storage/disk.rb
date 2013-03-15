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
		# Format class?
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

	def start_log(log_name, entry_description, log_length)
		entry_description = '(no description)' unless entry_description
		if update_current(log_name, entry_description, log_length)
			create_log(log_name) # Creates directory if it has not already been created
			git.add
			git.commit("Started log #{log_name}")
			true
		else
			false
		end
	end

	def stop_log(log_name)
		log_name = current_log_name unless log_name
		if stop_current
			delete_current(log_name)
			git.add
			git.commit("Stopped log #{log_name}")
			true
		else
			false
		end
	end

	def delete_log(log_name)
		if Dir.exists?(log_path(log_name))
			stop_log(log_name)
			all_log_dirs.each do |log_path|
				log_basename = log_path.basename.to_s
				if log_basename == log_name
					FileUtils.rm_rf(log_path) if log_basename == log_name 
					git.remove(log_path, {:recursive => "-r"})
					git.commit("Deleted log #{log_name}")
				end
			end
		else
			false
		end
	end

	def log_entries(log_name)
		if log_path(log_name)
			log_storage.log_path = log_path(log_name)
			log_storage.get_tlog_entries
		else
			nil
		end
	end

	def log_length(log_name)
		if log_path(log_name)
			log_storage.log_path = log_path(log_name)
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

	def cur_log_length
		if current_log_length
			current_log_length.to_i
		else
			nil
		end
	end

	def current_log_name
		File.open(current_path).first.strip if File.exists?(current_path)
	end

	def get_current_start_time 
		current_start_time
	end

	def all_log_dirs
		Pathname.new(logs_path).children.select { |c| c.directory? }
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

	private

	def init_tlog_branch(tlog_branch = false)
		in_branch(tlog_branch) do
			#File.open('.hold', 'w+'){|f| f.puts('hold')}
			unless tlog_branch
				git.add
				git.commit('creating the tlog branch')
			end
		end
	end

	def update_current(log_name, entry_description, log_length)
		puts "update_current called, log name is #{log_name}"
		puts "filename for current is #{current_path}"
		if !File.exists?(current_path)
			FileUtils.touch(current_path)
			write_to_current(log_name, entry_description, log_length)
			true
		else
			false
		end
	end

	def delete_current(log_name) # Change this method name or add one
		puts "delete_current called, log name is #{log_name}"
		if File.exists?(current_path)
			if current_log_name == log_name
				FileUtils.rm(current_path)
				git.remove(current_path)
			end
		else
			false
		end
	end	

	def write_to_current(log_name, entry_description, log_length)
		puts "entry_description is #{entry_description}"
		content = log_name + "\n" + Time.new.to_s + "\n" + entry_description
		content << "\n" + log_length.to_s if log_length
		File.open(current_path, 'w') { |f| f.write(content)}
	end

	def current_exists?
		Dir.exists?(current_path)
	end

	def stop_current
		if File.exists?(current_path)
			puts "current_entry_description is #{current_entry_description}"
			create_log_entry(current_log_name, current_start_time, current_log_length)
			true
		else
			false
		end
	end

	def current_start_time
		contents = File.read(current_path)
		contents.slice! current_log_name
		start_time = contents
		split_contents = contents.split(' ', 5)
		if split_contents.length == 5
			contents.slice! split_contents[4]
			start_time = contents
		end
		start_time.strip
	end

	def current_entry_description
		contents = File.read(current_path)
		contents.slice! current_log_name
		contents.split(' ', 5)[3]
	end

	def current_log_length
		contents = File.read(current_path)
		contents.slice! current_log_name
		split_contents = contents.split(' ', 5)
		if split_contents.length == 5
			log_length = split_contents[4]
		else
			nil
		end
	end

	def create_log_entry(name, start_time, log_length)
		log_storage.initial_log_length = log_length if log_length
		new_entry = Tlog::Task_Entry.new(Time.parse(start_time),Time.new, nil)
		update_log_storage(log_path(name), new_entry)
		log_storage.create_entry
	end

	def create_log(log_name)
		FileUtils.mkdir_p(log_path(log_name)) unless Dir.exists?(log_path(log_name))
	end

	def update_log_storage(log_path, log_entry)
		log_storage.log_path = log_path
		log_storage.entry = log_entry
	end

	def log_path(log_name)
		File.join(logs_path, log_name)
	end

	def logs_path
		File.expand_path(File.join('tasks'))
	end

	def current_path
		File.expand_path(File.join('current'))
	end

end