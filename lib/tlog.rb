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

	module App
	end

	module Error
	end

	module Model
	end

end



require 'tlog/translator'


