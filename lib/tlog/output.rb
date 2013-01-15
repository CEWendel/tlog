
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

end