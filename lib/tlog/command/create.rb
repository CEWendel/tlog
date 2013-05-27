
class Tlog::Command::Create < Tlog::Command

	def name
		"create"
	end

	def execute(input, output)
		raise Tlog::Error::CommandInvalid, "Must specify log name" unless input.args[0]

		log = Tlog::Entity::Log.new
		log.name = input.args[0];
		log.goal = ChronicDuration.parse(input.options[:goal]) if input.options[:goal]
		raise Tlog::Error::CommandNotFound, "Could create log: Log already exists" unless create_log(log)
	end

	def options(parser, options)
		parser.banner = "usage: tlog create <log_name>"

		parser.on("-g", "--goal <goal_length>") do |goal|
			options[:goal] = goal
		end
	end

	private

	def create_log(log)
		storage.in_branch do |wd|
			storage.create_log(log)
		end
	end
end