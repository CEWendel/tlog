
class Tlog::Command::Display < Tlog::Command

  def name
    "display"
  end

  def description
    "displays information about time logs. command options contrain which time logs are displayed"
  end 

  def execute(input, output)
    display(input.args[0], input.options, output)
  end

  def options(parser, options)
    parser.banner = "usage: tlog display #{$0} [options]"

    parser.on("-g", "--goal <goal_threshold>") do |goal|
      options[:goal] = goal
    end

    parser.on("-o", "--owner a,b,c", Array, "Array of owners to display") do |owners|
      options[:owners] = owners
    end

    parser.on("-p", "--points <points_threshold>") do |points|
      options[:points] = points.to_i
    end

    parser.on("-s", "--state a,b,c", Array, "Array of states to display") do |states|
      options[:states] = states
    end

  end

  # Methods that filter which logs should be displayed

  def log_goal_valid(log, thresholds)
    goal_threshold = thresholds[:goal]
    goal_threshold = ChronicDuration.parse(goal_threshold)
    return false unless log.goal
    goal_threshold >= log.goal ? valid = true : valid = false
    valid
  end

  def log_owners_valid(log, thresholds)
    owners = thresholds[:owners]
    owners.each do |owner|
      return true if log.owner == owner
    end
    false
  end

  def log_points_valid(log, thresholds)
    points_value = thresholds[:points]
    log.points >= points_value ? valid = true : valid = false
    valid
  end

  def log_states_valid(log, thresholds)
    states = thresholds[:states]
    states.each do |state|
      return true if log.state.downcase == state.downcase
    end
    false
  end

  private

  def display(log_name, options, output)
    storage.in_branch do |wd|
      if storage.all_log_dirs
        if log_name
          display_log(log_name, options, output)
        else  
          display_all(options, output)
        end 
      else
        output.line("No time logs yet");
      end
    end
  end

  def display_log(log_name, options, output)
    log = storage.require_log(log_name)
    raise Tlog::Error::CommandInvalid, "Time log '#{log_name}' does not exist" unless log
    
    log_length = log.goal_length
    entries = log.entries
    if storage.start_time_string && is_current_log_name?(log_name)
      start_time = Time.parse(storage.start_time_string)
    end
    return unless log_valid?(log, options)

    # Print out time log information
    print_log_info(log, output)
    print_header(output)
    print_current(log_name, log_length, start_time, output)
    display_entries(entries, output) if entries
    print_footer(log, log_length, output)
  end

  def display_all(options, output)
    storage.all_log_dirs.each do |log_path|
      log_basename = log_path.basename.to_s
      display_log(log_basename, options, output)
    end
  end

  def log_valid?(log, thresholds = {})
    thresholds.each do |key, value|
      attribute_value = key.to_s
      log_valid_method = "log_#{attribute_value}_valid"
      if respond_to?(log_valid_method)
        return false unless self.send(log_valid_method, log, thresholds)
      end
    end
    true
  end

  def display_entries(entries, output)
    if entries.size > 0
      entries.each do |entry|
        out_str = "\t%-4s  %16s%12s           %s" % [
          date_time_format.timestamp(entry.time[:start]),
          date_time_format.timestamp(entry.time[:end]),
          seconds_format.duration(entry.length.to_s),
          entry.description,
        ]
        output.line(out_str)
      end
    end
  end

  def print_footer(log, log_length, output)
    output.line "-" * 100
    print_total(log, output)
    print_time_left(log, output)
  end

  def print_header(output)
    output.line("\tStart               End                    Duration          Description")
  end 

  def print_total(log, output)
    #output.line("-") * 52
    duration = log.duration
    if storage.current_log_name == log.name
      duration += storage.time_since_start
    end
    output.line("\tTotal%45s " % seconds_format.duration(duration))
  end

  def print_log_info(log, output)
    out_str = "Log:    #{log.name}\nState:  #{log.state}\nPoints: #{log.points}\nOwner:  #{log.owner}"
    output.line_yellow(out_str)
  end

  def print_time_left(log, output)
    if log.goal
      log_goal = log.goal
      if (storage.current_log_name == log.name)
        current_time = Time.now - storage.cur_start_time
        log_goal -= current_time.to_i
      end
      log_goal = 0 if log_goal < 0
      output.line_red("\tTime left: %39s" % seconds_format.duration(log_goal)) 
    end
  end

  #should be added to entries array, not its own seperate thing
  def print_current(log_name, log_length, current_start_time, output)
    if is_current_log_name?(log_name)
      formatted_length = seconds_format.duration storage.time_since_start
      out_str = out_str = "\t%-4s  %16s%14s         %s" % [
        date_time_format.timestamp(current_start_time),
        nil,
        formatted_length,
        storage.cur_entry_description, 
      ]
      output.line(out_str)
      storage.time_since_start
    end
  end

  def update_log_length(log_length)
    log_length - storage.time_since_start if log_length
  end

  def is_current_log_name?(log_name)
    if storage.current_log_name == log_name
      true
    else
      false
    end
  end
end