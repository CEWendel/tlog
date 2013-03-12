class Tlog::Format::Seconds

	def self.duration(total_seconds)
		output = ""
		total_seconds ||= 0
		total_seconds = total_seconds.to_i
		mm, ss = total_seconds.divmod(60)
		hh, mm = mm.divmod(60)
		output = "%2s:%02d:%02d" % [hh, mm, ss]
		return output
	end

end