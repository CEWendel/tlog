class Tlog::Command::Stop < Tlog::Command

  def name 
    "stop"
  end 

  def description
    "ends a task for a time log"
  end

  def execute(input, output)
    updated_log = stop
    output.line("Stopped '#{updated_log.name}'")
  end

  def options(parser, options)
    parser.banner = "usage: tlog stop"
  end

  private

  def stop
    storage.in_branch do |wd|
      checked_out_log = storage.checkout_value
      raise Tlog::Error::CheckoutInvalid, "No time log is checked out" unless checked_out_log
      log = storage.require_log(checked_out_log)
      raise Tlog::Error::TimeLogNotFound, "Time log '#{checked_out_log}' does not exist" unless log
      unless storage.stop_log(log)
        raise Tlog::Error::CommandInvalid, "Failed to stop log '#{checked_out_log}': This time log is not in progress"
      end
      log
    end
  end

end