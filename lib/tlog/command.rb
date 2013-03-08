class Tlog::Command

	attr_accessor :storage
	attr_reader :seconds_format
	attr_reader :timestamp_format

	def initialize
		@seconds_format = Tlog::Format::Seconds
		@date_time_format = Tlog::Format::DateTime
	end

	def execute(input, output)
		raise NotImplementedError
	end

	def options(parser, options)
	end

end