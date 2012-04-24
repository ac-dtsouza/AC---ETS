module RootHelper

	def ln(str)
		raw str+"\n"
	end
	
	def lt(str)
		raw "\t"+str
	end
	
	def options_from_collection_for_select(users, selected)
		tmp = "\n"
		users.each do |user|
			tmp += ln lt "<option #{"selected='selected'" if user["user_id"] == selected} value='#{user["user_id"]}'>#{user["user_name"]}</option>"
		end
		raw tmp
	end

end
