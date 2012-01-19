class User < ActiveRecord::Base
	validates :name,  :presence => true
	validates :pass,  :presence => true
end
