class Tlog::Command

	attr_accessor :storage
	attr_accessor :seconds_format
	attr_accessor :date_time_format

	def execute(input, output)
		raise NotImplementedError
	end

	def options(parser, options)
	end

end