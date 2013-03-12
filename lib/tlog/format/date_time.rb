class Tlog::Format::DateTime

	def self.timestamp(gmt_time)
		gmt_time.strftime("%B %d, %I:%M%p")
	end

end