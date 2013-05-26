
# Helper class for printing out active time logs
class Tlog::Entity::Active_Log
	attr_accessor :name
	attr_accessor :current

	def initialize(name)
		@name = name
		@current = false
	end
end