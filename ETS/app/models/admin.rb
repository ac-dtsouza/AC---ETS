class Admin < ActiveRecord::Base
	def self.is_admin?(user_id)
		admin = self.find_by_user_id(user_id)
		admin.nil? ? false : true
	end
end
