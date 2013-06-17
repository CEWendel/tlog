
class Tlog::Output

  attr_accessor :stdout
  attr_accessor :stderr

  def initialize(stdout,stderr)
    @stdout = stdout
    @stderr = stderr
  end

  def error(err)
    @stderr.puts err
  end

  def line(out)
    @stdout.puts out
    true
  end

  def line_yellow(out)
    @stdout.puts out.yellow
  end

  def line_red(out)
    @stdout.puts out.red
  end

  def line_blue(out)
    @stdout.puts out.blue
  end

end