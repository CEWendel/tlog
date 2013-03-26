require 'fileutils'
require 'securerandom'
require 'pathname'
require 'time'
require 'chronic'
require 'git'

class Tlog::Storage::Disk

	attr_accessor :git
	attr_accessor :tlog_dir
	attr_accessor :tlog_working
	attr_accessor :tlog_index
	attr_accessor :working_dir
	attr_accessor :log_storage

	# Class methods 'create_repo' 'all_logs', also 'create' command

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

	def read_logs
		all_logs = []
		all_log_dirs.each do |log_path|
			log = Tlog::Entity::Log.new
			log_storage.log_path = log_path
			log.name = log_path.basename
			puts "log name is #{log.name}"
			log.entries = log_storage.get_tlog_entries
			puts "log entries are #{log.entries}"
			log.goal = log_storage.get_tlog_length
			puts "log goal is #{log.goal}"
			all_logs.push(log)
		end
		all_logs
	end

	def create_log(log)
		path = log_path(log.name)
		unless Dir.exists?(path)
			FileUtils.mkdir_p(path)
			log_storage.log_path = path
			log_storage.update_head(log.goal)
			git.add
			git.commit("Created log #{log.name}")
			true
		else
			false
		end
	end

	def require_log(log)
		decode_log_path(log_path(log.name))
	end

	def decode_log_path(log_path)
		if Dir.exists?(log_path)
			log = Tlog::Entity::Log.new
			log_storage.log_path = log_path
			log.name = log_path.basename
			log.entries = log_storage.get_tlog_entries
			log.goal = log_storage.get_tlog_length
		end
		return log
	end

	def start_log(log_name, entry_description, log_length)
		puts "entry_description is #{entry_description}"
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

	def log_length(log_name) # change to goal
		if log_path(log_name)
			log_storage.log_path = log_path(log_name)
			log_storage.get_tlog_length
		else
			nil
		end
	end

	def log_duration(log_name)
		duration = 0
		if current_log_name == log_name
			duration += time_since_start
		end
		log_entries(log_name).each do |entry| # should just be able to do log.entries.each
			duration += entry.length
		end
		duration
	end

	def find_repo(dir)
		full = File.expand_path(dir)
		ENV["GIT_WORKING_DIR"] || loop do
			return full if File.directory?(File.join(full, ".git"))
			raise "No Repo Found" if full == full=File.dirname(full)
		end
	end

	def start_time_string
		current_start_time
	end

	def time_since_start
		if Dir.exists?(current_path)
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

	def cur_entry_owner
		git.config["user.email"].split('@').first rescue ''
	end

	def cur_entry_description
		current_entry_description
	end

	def current_log_name
		name_contents = File.read(current_name_path) if File.exists?(current_name_path)
		name_contents.strip if name_contents
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
		unless Dir.exists?(current_path)
			FileUtils.mkdir_p(current_path)
			write_to_current(log_name, entry_description, log_length)
			true
		else
			false
		end
	end

	def delete_current(log_name) # Change this method name or add one
		puts "delete_current called, log name is #{log_name}"
		if Dir.exists?(current_path)
			if current_log_name == log_name
				FileUtils.rm_rf(current_path)
				git.remove(current_path, {:recursive => 'r'})
			end
		else
			false
		end
	end	

	def write_to_current(log_name, entry_description, log_length)
		puts "entry_description is #{entry_description}"
		# Create a current object, with a "read" method
		File.open(current_name_path, 'w'){ |f| f.write(log_name)} 
		File.open(current_description_path, 'w'){ |f| f.write(entry_description)} if entry_description
		File.open(current_length_path, 'w') { |f| f.write(log_length)} if log_length
		File.open(current_start_path, 'w'){ |f| f.write(Time.now.to_s)} 
	end

	def current_exists?
		Dir.exists?(current_path)
	end

	def stop_current
		if Dir.exists?(current_path)
			puts "current_entry_description is #{current_entry_description}"
			create_log_entry(current_log_name, current_start_time, current_log_length, current_entry_description) # CURRENT OBJECT!
			true
		else
			false
		end
	end

	#Eventually want to take this out and just create the entry on start
	def current_start_time
		read_file(current_start_path)
	end

	def current_entry_description
		read_file(current_description_path)
	end

	def current_log_length
		read_file(current_length_path)
	end

	def read_file(path)
		if File.exists?(path)
			contents = File.read(path)
			contents.strip
		else
			nil
		end
	end

	def create_log_entry(name, start_time, log_length, log_description)
		log_storage.initial_log_length = log_length if log_length
		new_entry = Tlog::Task_Entry.new(Time.parse(start_time),Time.new, nil, log_description, cur_entry_owner)
		update_log_storage(log_path(name), new_entry)
		log_storage.create_entry
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

	def current_name_path
		File.join(current_path, 'NAME')			
	end

	def current_start_path
		File.join(current_path, 'START')
	end

	def current_length_path
		File.join(current_path, 'LENGTH')
	end 

	def current_description_path
		File.join(current_path, 'DESCRIPTION')
	end 

end