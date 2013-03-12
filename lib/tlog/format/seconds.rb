class Tlog::Format::Seconds

	def self.duration(total_seconds)
		total_seconds ||= 0
		total_seconds = total_seconds.to_i
		output = "%2s:%02d:%02d" % [total_seconds/3600, (total_seconds%3600)/60, total_seconds % 60]
		return output
	end

end