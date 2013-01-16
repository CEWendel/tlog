
require 'fileutils'

class Tlog::Storage

	attr_accessor :working_dir

	def initialize(working_dir)	
		@working_dir = working_dir #ie /Users/ChrisW/Documents/Ruby/Jeah
	end
=begin

	def init_project(path)	
		raise TLog::Error::ProjectExists if File.exists? filename_for_working_dir
		puts "Initialized project"
	end


	private

	def filename_for_working_dir
		File.join(@working_dir.path, ".tlog")
	end
=end

end