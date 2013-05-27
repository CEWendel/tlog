
class Tlog::Entity::Log

	attr_accessor :name
	attr_accessor :goal
	attr_accessor :entries
	attr_accessor :path

	def initialize(log_path = nil)
		@entries = []
		if log_path
			@name = log_path.basename.to_s
			@path = log_path
			@goal = goal_length
		end
	end

	def goal_length
		if File.exists?(goal_path)
			contents = File.read(goal_path)
			contents.strip
			contents.to_i
		end
	end
	

	def entries
		log_entries = []
		hex_value = head_hex_value
		return log_entries unless hex_value
		begin
			entry = Tlog::Task_Entry.new(entry_path(hex_value), hex_value)
			hex_value = entry.parent_hex
			log_entries.push(entry)
		end until hex_value == "none"
		return log_entries
	end

	def duration
		dur = 0
		entries.each do |entry|
			dur += entry.length
		end
		dur
	end

	def create
		unless Dir.exists?(@path)
			FileUtils.mkdir_p(@path)
			File.open(goal_path, 'w'){|f| f.write(@goal)} if @goal
			true
		end
	end

	def add_entry(current)
		entry_hex = generate_random_hex
		new_entry = Tlog::Task_Entry.new(entry_path(entry_hex), entry_hex)
		head_hex_value ? parent_hex = head_hex_value : parent_hex = "none"

		update_head(entry_hex)
		new_entry.create(parent_hex, current)
		update_goal(new_entry.length) if goal_length
	end

	def update_head(entry_hex)
		File.open(head_path, 'w'){|f| f.write(entry_hex)}
	end

	def update_goal(entry_length)
		puts "entry_length is #{entry_length}"
		puts "goal length is #{goal_length}"
		new_length = goal_length - entry_length
		puts "new length is #{new_length}"
		File.open(goal_path, 'w'){|f| f.write(new_length)}
	end

	def delete
		FileUtils.rm_rf(@path) if Dir.exists?(@path)
	end

	private

	def head_hex_value
		if File.exists?(head_path)
			head_content = File.read(head_path)
			head_content.strip if head_content
		end
	end

	def goal_path
		File.join(@path, 'GOAL')
	end

	def head_path
		File.join(@path, 'HEAD')
	end

	def entry_path(hex)
		File.join(@path, hex)
	end

	def generate_random_hex
		SecureRandom.hex(13)
	end 
end