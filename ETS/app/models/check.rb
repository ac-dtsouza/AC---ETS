class Check < ActiveRecord::Base
	def self.insert(user_id, timestamp)
		if user_id.nil? || timestamp.nil?
			false
		else
			user_id = sanitize(user_id).to_s[1..-2] # Get rid of "'*'"
			this = self.new(:user_id => user_id, :check_timestamp => Time.parse(timestamp).utc.to_s(:db))
			this.save
		end
	end
	
	def self.update(user_id, date, newtime, oldtime)
		if user_id.nil? || date.nil? || newtime.nil? || oldtime.nil?
			false
		else
			user_id = sanitize(user_id)
			timestamp = sanitize("#{date} #{oldtime}")
			this = self.where("user_id = #{user_id} and DATETIME(check_timestamp, 'localtime') = #{timestamp}").first
			this["check_timestamp"] = Time.parse("#{date} #{newtime}").utc.to_s(:db)
			this.save
		end
	end
	
	def self.delete(user_id, timestamp)
		if user_id.nil? || timestamp.nil?
			[].length
		else
			user_id = sanitize(user_id)
			timestamp = sanitize(timestamp)
			self.delete_all "user_id = #{user_id} AND DATETIME(check_timestamp, 'localtime') = #{timestamp}"
		end
	end
	
	def self.day(user_id, date)
		if user_id.nil? || date.nil?
			[]
		else
			user_id = sanitize(user_id)
			connection.select_all "
			SELECT 
			DATE(checks.check_timestamp) as date,
			TIME(checks.check_timestamp, 'localtime') as time
			
			FROM 
			checks
			
			WHERE
			checks.user_id = #{user_id}
			AND DATE(checks.check_timestamp) = DATE('#{date}')
			"
		end
	end
	
	def self.month(user_id, first, last)
		if user_id.nil? || first.nil? || last.nil?
			[]
		else
			user_id = sanitize(user_id)
			connection.select_all "
			
			SELECT 
			DATE(checks.check_timestamp) as date,
			TIME(checks.check_timestamp, 'localtime') as time
			
			FROM 
			checks
			
			WHERE
			checks.user_id = #{user_id}
			AND DATE(checks.check_timestamp) BETWEEN DATE('#{first}') AND DATE('#{last}')
			
			ORDER BY
			checks.check_timestamp
			
			"
		end
		#sort by date asc
	end
end
