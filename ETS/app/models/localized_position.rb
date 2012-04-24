class LocalizedPosition < ActiveRecord::Base
	#def self.copy
	#	pos = connection.select_all "
	#	SELECT
	#	*
	#	
	#	FROM
	#	positions
	#	"
	#	
	#	pos.each do |v|
	#		add = []
	#		v.each do |key, value|
	#			add.push(value)
	#		end
	#		connection.execute 'INSERT INTO localized_positions("id", "position_id", "position_desc_en", "position_workload", "created_at", "updated_at") VALUES('+add.to_s.tr('\[\]', '')+')'
	#	end
	#end
end
