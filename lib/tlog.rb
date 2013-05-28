
module Tlog
	Version = "0.0.0"

	module Storage
	end

	module Error
	end

	module Format
	end

	module Entity
	end
end

require "chronic_duration"
require 'fileutils'
require 'git'
require 'securerandom'
require 'pathname'
require 'time'
require 'chronic'

require 'tlog/command'
require 'tlog/command/init'
require 'tlog/command/start'
require 'tlog/command/stop'
require 'tlog/command/active'
require 'tlog/command/delete'
require 'tlog/command/display'
require 'tlog/command/create'

require 'tlog/storage/disk'

require 'tlog/format/seconds'
require 'tlog/format/date_time'

require 'tlog/entity/log'
require 'tlog/entity/active_log'
require 'tlog/entity/entry'

require 'tlog/error'



