class Justification < ActiveRecord::Base
	def self.insert(user_id, date, motive)
		if user_id.nil? || date.nil? || motive.nil?
			false
		else
			user_id = sanitize(user_id).to_s[1..-2] # Get rid of "'*'"
			this = self.new(:user_id => user_id, :date => date, :motive => motive)
			this.save
		end
	end
	
	def self.count(user_id, first, last)
		if user_id.nil? || first.nil? || last.nil?
			[].length
		else
			user_id = sanitize(user_id)
			array = connection.select_all "
			
			SELECT 
			justifications.date
			
			FROM 
			justifications
			
			WHERE
			justifications.user_id = #{user_id}
			AND DATE(justifications.date) BETWEEN DATE('#{first}') AND DATE('#{last}')
			
			"
			array.length
		end
		
	end
end
