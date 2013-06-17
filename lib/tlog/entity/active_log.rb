
# Helper class for printing out active time logs
class Tlog::Entity::Active_Log
  attr_reader :name
  attr_accessor :current
  attr_accessor :checked_out

  def initialize(name)
    @name = name
    @current = false
    @checked_out = false
  end
end