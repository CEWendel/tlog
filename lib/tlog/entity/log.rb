class Tlog::Entity::Log

	attr_accessor :name
	attr_accessor :goal
	attr_accessor :entries

	def initialize 
		@entries = []
	end
end