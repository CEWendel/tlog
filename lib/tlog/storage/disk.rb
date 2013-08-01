
class Tlog::Storage::Disk

  attr_accessor :git
  attr_accessor :tlog_dir
  attr_accessor :tlog_working
  attr_accessor :tlog_index
  attr_accessor :working_dir

  def initialize(git_dir) 
    @git = Git.open(find_repo(git_dir))
    proj_path = @git.dir.path.downcase.gsub(/[^a-z0-9]+/i, '-')

    @tlog_dir = '~/.tlog'
    @tlog_working = File.expand_path(File.join(@tlog_dir, proj_path, 'working'))
    @tlog_index = File.expand_path(File.join(@tlog_dir, proj_path, 'index'))

    bs = git.lib.branches_all.map{|b| b.first}

    unless(bs.include?('tlog') && File.directory?(@tlog_working))
      init_tlog_branch(bs.include?('tlog'))
    end
  end

  def checkout_log(log)
    File.open(checkout_path, 'w'){|f| f.write(log.name)}
    git.add
    git.commit("Checking out time log '#{log.name}'")
  end

  def checkout_value
    read_file(checkout_path) if File.exists?(checkout_path)
  end

  def create_log(log, options = {})
    log.path = log_path(log.name)
    options[:owner] = cur_user
    if log.create(options)
      git.add
      git.commit("Created log '#{log.name}'")
      true
    else
      false
    end
  end

  def push_logs
    git.push('origin', 'tlog:tlog')
  end

  def pull_logs
    git.pull('origin', 'origin/tlog')
  end

  def delete_log(log)
    log.path = log_path(log.name)
    log.delete
    delete_current(log.name)
    delete_checkout(log.name)

    # Recursively removes the directory that stores the time log
    git.remove(log.path, {:recursive => "-r"})
    git.commit("Deleted log '#{log.name}'")
  end

  def require_log(log_name)
    decode_log_path(Pathname.new(log_path(log_name))) if logs_path
  end

  def start_log(log, entry_description)
    entry_description = '(no description)' unless entry_description
    if update_current(log.name, entry_description)
      create_log(log) # Creates directory if it has not already been created
      git.add
      git.commit("Started log '#{log.name}'")
      true
    else
      false
    end
  end

  def stop_log(log)
    if Dir.exists?(current_path) and log.name == checkout_value
      current_hash = { 
        :name => current_log_name,
        :start_time => current_start_time,
        :description => current_entry_description,
      }
      delete_current(current_hash[:name])
      log.add_entry(current_hash)

      git.add
      git.commit("Stopped log '#{log.name}'")
      true
    else
      false
    end
  end

  def change_log_state(log, new_state)
    log.path = log_path(log.name)
    log.update_state(new_state)

    git.add
    git.commit("Changed state for time log #{log.name}")
  end

  def change_log_points(log, new_points_value)
    log.path = log_path(log.name)
    log.update_points(new_points_value)

    git.add
    git.commit("Changed points value for time log #{log.name}")
  end

  def change_log_owner(log, new_owner)
    log.path = log_path(log.name)
    log.update_owner(new_owner)

    git.add
    git.commit("Changed owner for time log #{log.name}")
  end

  def log_duration(log_name)
    duration = 0
    if current_log_name == log_name
      duration += time_since_start
    end
    log_entries(log_name).each do |entry|
      duration += entry.length
    end
    duration
  end

  def find_repo(dir)
    full = File.expand_path(dir)
    ENV["GIT_WORKING_DIR"] || loop do
      return full if File.directory?(File.join(full, ".git"))
      raise "No Repo Found" if full == full=File.dirname(full)
    end
  end

  def start_time_string
    current_start_time
  end

  def cur_user
    git.config["user.email"].split('@').first rescue ''
  end

  def time_since_start
    if Dir.exists?(current_path)
      difference = Time.now - Time.parse(current_start_time)
      difference.to_i
    else
      nil
    end
  end

  def cur_start_time
    Time.parse(current_start_time) if current_start_path
  end

  def cur_entry_description
    current_entry_description
  end

  def current_log_name
    name_contents = File.read(current_name_path) if File.exists?(current_name_path)
    name_contents.strip if name_contents
  end

  def get_current_start_time 
    current_start_time
  end

  def all_log_dirs
    Pathname.new(logs_path).children.select { |c| c.directory? } if Dir.exists?(logs_path)
  end

  def current_branch
    git.lib.branch_current
  end

  # Temporarily switches to tlog branch 
  def in_branch(branch_exists = true)
    unless File.directory?(@tlog_working)
      FileUtils.mkdir_p(@tlog_working)
    end

    old_current = current_branch
    begin
      git.lib.change_head_branch('tlog')
      git.with_index(@tlog_index) do 
        git.with_working(@tlog_working) do |wd|
          git.lib.checkout('tlog') if branch_exists
          yield wd
        end
      end
    ensure
      git.lib.change_head_branch(old_current)
    end
  end

  def commit_working_changes(message)
    # Commit tracked working changes in current branch
    git.commit_all(message)
  end

  private

  def decode_log_path(log_path)
    if Dir.exists?(log_path)
      log = Tlog::Entity::Log.new(log_path)
    end
    return log
  end

  def init_tlog_branch(tlog_branch = false)
    in_branch(tlog_branch) do
      File.open('.hold', 'w+'){|f| f.puts('hold')}
      unless tlog_branch
        git.add
        git.commit('creating the tlog branch')
      end
    end
  end

  def update_current(log_name, entry_description)
    unless Dir.exists?(current_path)
      FileUtils.mkdir_p(current_path)
      write_to_current(log_name, entry_description)
      true
    else
      false
    end
  end

  def delete_current(log_name)
    if Dir.exists?(current_path)
      if current_log_name == log_name
        FileUtils.rm_rf(current_path)
        git.remove(current_path, {:recursive => 'r'})
      end
    else
      false
    end
  end 

  def delete_checkout(log_name)
    if File.exists?(checkout_path)
      if checkout_value == log_name
        FileUtils.rm(checkout_path)
      end
    else
      false
    end
  end 

  def write_to_current(log_name, entry_description)
    # Create a current object, with a "read" method
    File.open(current_name_path, 'w'){ |f| f.write(log_name)} 
    File.open(current_description_path, 'w'){ |f| f.write(entry_description)} if entry_description
    File.open(current_start_path, 'w'){ |f| f.write(Time.now.to_s)} 
  end

  def current_exists?
    Dir.exists?(current_path)
  end

  def stop_current
    if Dir.exists?(current_path)
      create_log_entry(current_log_name, current_start_time, current_entry_description) # CURRENT Dictionary?!
      true
    else
      false
    end
  end

  #Eventually want to take this out and just create the entry on start
  def current_start_time
    read_file(current_start_path)
  end

  def current_entry_description
    read_file(current_description_path)
  end

  def current_log_length
    read_file(current_length_path)
  end

  def read_file(path)
    if File.exists?(path)
      contents = File.read(path)
      contents.strip
    else
      nil
    end
  end

  def log_path(log_name)
    File.join(logs_path, log_name)
  end

  def goal_path(log_name)
    File.join(log_path(log_name), 'GOAL')
  end

  def logs_path
    File.expand_path(File.join('tasks'))
  end

  def checkout_path
    File.join(logs_path, 'CHECKOUT');
  end

  def current_path
    File.expand_path(File.join('current'))
  end

  def current_name_path
    File.join(current_path, 'NAME')     
  end

  def current_start_path
    File.join(current_path, 'START')
  end

  def current_length_path
    File.join(current_path, 'LENGTH')
  end 

  def current_description_path
    File.join(current_path, 'DESCRIPTION')
  end 

end