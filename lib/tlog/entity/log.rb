
class Tlog::Entity::Log

	attr_accessor :name
	attr_accessor :goal
	attr_accessor :entries
	attr_accessor :path

	def initialize 
		@entries = []
	end

	def create
		FileUtils.mkdir_p(@path) unless Dir.exists?(@path)
	end

	private
end