class MonthBank < ActiveRecord::Base
	def self.create(id, start, month)
		m = Month.new(:bankofhours_id => id, :start_hours => start, :month => month)
		puts m
	end
end
