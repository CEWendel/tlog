
class Tlog::Command::State < Tlog::Command

  def name 
    "state"
  end 

  def description
    "changes the state of the checked-out time log"
  end

  def execute(input, output)
    new_state = input.args[0]
    updated_log = change_state(new_state)
    output.line("Changed state of '#{updated_log.name}' to #{new_state}")
  end

  def options(parser, options)
    parser.banner = "usage: tlog state <new_state>"
  end

  private

  def change_state(new_state)
    storage.in_branch do |wd|
      checked_out_log = storage.checkout_value
      raise Tlog::Error::CheckoutInvalid, "No time log is checked out" unless checked_out_log
      log = storage.require_log(checked_out_log)
      raise Tlog::Error::TimeLogNotFound, "Time log '#{checked_out_log}' does not exist" unless log
      storage.change_log_state(log, new_state)
      log
    end
  end
end