
class Tlog::Command::Pull < Tlog::Command

	def name
		"pull"
	end

	def description 
		"pulls time logs from upstream"
	end

	def execute(input, output)
		pull_logs
	end

	def options(parser, options)
		parser.banner = "usage: tlog pull"
	end

	private

	def pull_logs
		storage.in_branch do |wd|
			storage.pull_logs
		end
	end
end