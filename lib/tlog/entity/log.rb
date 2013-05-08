
class Tlog::Entity::Log

	attr_accessor :name
	attr_accessor :goal
	attr_accessor :entries
	attr_accessor :path

	def initialize 
		@entries = []
	end

	def create
		unless Dir.exists?(@path)
			FileUtils.mkdir_p(@path)
			File.open(goal_path, 'w'){|f| f.write(@goal)} if @goal
		end
	end

	private
	
	def goal_path
		File.join(@path, 'GOAL')
	end
end