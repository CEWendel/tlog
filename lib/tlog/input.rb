
class Tlog::Input
  attr_accessor :args
  attr_accessor :options

  def initialize(args=[])
    @args = args
    @options = {}
  end
end