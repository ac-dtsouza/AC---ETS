class Holiday < ActiveRecord::Base
	def self.check(date)
		h = self.find_by_day(date)
		return !h.blank?
	end
	def self.checkBetween(first, last)
		h = connection.select_all "select * from holidays where DATE(day) between date('#{first}') and date('#{last}')"
		return h.length
	end
	def self.create(date, text)
		h = self.new(:day => date, :desc => text)
		h.save
	end
	def self.current
		h = connection.select_all "select * from holidays where strftime('%Y', day) = '#{Date.current.year}' order by day"
		h
	end
	def self.update(id, day, desc)
		u = self.find_by_id(id)
		u.day = day
		u.desc = desc
		u.save
	end
end
