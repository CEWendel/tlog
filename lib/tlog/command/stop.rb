class Tlog::Command::Stop < Tlog::Command

	def name 
		"stop"
	end 

	def execute(input, output)
		raise Tlog::Error::CommandInvalid, "Must specify log name" unless input.args[0]
		stop(input.args[0])
	end

	def options(parser, options)
		parser.banner = "usage: tlog stop <log_name>"
	end

	private

	def stop(log_name)
		storage.in_branch do |wd|
			log = storage.require_log(log_name)
			storage.stop_log(log)
		end
	end

end