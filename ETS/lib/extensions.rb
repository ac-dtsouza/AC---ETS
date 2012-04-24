class Object
	def toNX(int, n)
		return toNX("0#{int}", n-1) if n > 0
		int.to_s
	end
	
	def toXX(int)
		# 1 = "01"
		# 10 = "10"
		int < 10 ? toNX(int, 1) : int.to_s
	end

	def floatToHours(float)
		# 5.75421666... = 05:45:15
		# 1.1308333333333329
		# Gets the absolute value of float
		# Stores the proper signal for the return string
		if float < 0.0
			signal = "-"
			float = (-float)
		else
			signal = ""
		end
		
		hh = float.to_i
		float -= hh
		float = (float*60)
		mm = float.to_i
		float -= mm
		float = (float*60)+0.5
		ss = float.to_i
		"#{signal}#{toXX(hh)}:#{toXX(mm)}:#{toXX(ss)}"
	end
	
	def hoursToFloat(hours)
		# "05:45:15" = 5+0.75+0.004167 = 5.75421666...
		# "-05:45:15" = -(hoursToFloat("05:45:15"))
		return -(hoursToFloat(hours[1..hours.length-1])) if hours[0] == '-'
		(hours[0..1].to_i+(hours[3..4].to_f/60)+(hours[6..7].to_f/3600)+0.00005)
	end
end