
# Simple helper class that handles an array of commands
class Tlog::Command_Suite 

  class << self
    def commands
      storage = self.working_dir_storage
      commands = [
        Tlog::Command::Start.new,
        Tlog::Command::Stop.new,
        Tlog::Command::Help.new,
        Tlog::Command::All.new,
        Tlog::Command::Delete.new,
        Tlog::Command::Display.new,
        Tlog::Command::Create.new,
        Tlog::Command::Checkout.new,
        Tlog::Command::State.new,
        Tlog::Command::Points.new,
        Tlog::Command::Owner.new,
        Tlog::Command::Push.new,
        Tlog::Command::Pull.new,
      ]
      commands.each do |command|
        command.storage = storage
        command.seconds_format = Tlog::Format::Seconds
        command.date_time_format = Tlog::Format::DateTime 
      end
      commands
    end

    def working_dir_storage
      Tlog::Storage::Disk.new('.')
    end
  end

end