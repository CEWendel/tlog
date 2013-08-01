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
    current_branch = storage.current_branch
    if input.options[:all]
      commit_working_changes(input.options[:message])
      commit_message = input.options[:message]
      output.line("Commiting tracked changes on current branch")
      output.line("#{ [current_branch] } #{commit_message}")
    end
  end

  def options(parser, options)
    parser.banner = "usage: tlo stop"

    parser.on("-a", "--all", "Stop current time log and commit tracked working changes") do |all|
      options[:all] = all
    end

    parser.on("-m", "--message <commit_message>", "The commit message you want to be associated with this commit") do |message|
      options[:message] = message
    end
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

  def commit_working_changes(message)
    storage.commit_working_changes(message)
  end
end