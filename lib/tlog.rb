#class Tlog
#  def self.hi(language = :english)
#    translator = Translator.new(language)
#   translator.hi
#  end
#end


=begin
class Tlog 
  def self.hi(language = :english)
    translator = Translator.new(language)
    translator.hi
  end
end
=end

module Tlog
	Version = "0.0.0"

	module Storage
	end

	module Error
	end

	module Format
	end
end

require 'tlog/command'
require 'tlog/command/test'
require 'tlog/command/init'
require 'tlog/command/start'
require 'tlog/command/stop'
require 'tlog/command/active'
require 'tlog/command/delete'
require 'tlog/command/log'

require 'tlog/task'

require 'tlog/task_entry'

require 'tlog/storage/disk'
require 'tlog/storage/task_store'

require 'tlog/format/seconds'
require 'tlog/format/date_time'


require 'tlog/error'



