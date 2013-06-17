
class Tlog::Command::Push < Tlog::Command

  def name
    "push"
  end

  def description 
    "pushes your time logs upstream"
  end

  def execute(input, output)
    push_logs
  end

  def options(parser, options)
    parser.banner = "usage: tlog push"
  end

  private

  def push_logs
    storage.in_branch do |wd|
      storage.push_logs
    end
  end
end