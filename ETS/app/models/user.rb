class User < ActiveRecord::Base
  def self.employee(user_id=nil, locale="pt")
	where = user_id.nil? ? "" : "
	WHERE
	users.user_id = '#{user_id}'"
	
    connection.select_all "
	SELECT 
	users.*,
	localized_positions.position_desc_en,
	localized_positions.position_desc_pt,
	localized_positions.position_workload,
	banks.bank_hours,
	banks.last_reset,
	banks.next_reset
	
	FROM 
	users 
	
	LEFT OUTER JOIN 
	localized_positions 
	
	ON 
	localized_positions.position_id = users.position_id
	
	LEFT OUTER JOIN 
	banks 
	
	ON 
	banks.bankofhours_id = users.bankofhours_id
	#{where}"
  end
end
