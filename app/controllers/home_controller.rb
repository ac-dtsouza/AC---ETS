class HomeController < ApplicationController
	
	def index
		if session[:user].blank?
			@user = "Stranger"
			@unsigned = true
		else
			@user = session[:user]
			@unsigned = false
		end
	end
	
	def sign
		if params[:user].blank?
			sign_fail
		else
			if params[:pass].blank?
				sign_fail
			else
				u = User.where( :name => params[:user], :pass => params[:pass] )
				if u.size == 1
					sign_success
				else
					sign_fail
				end
			end
		end
	end
	
	def logoff
		session[:user] = nil
		go_home
	end
	
	def profile
		@user = session[:user]
		go_home if @user.blank?
	end
	
		def sign_fail
			@msg = "Login Failed <script> alert('Login failed.\\nPlease check your information.'); window.location='/'; </script>"
		end
		
		def sign_success
			@msg = "Logging In <script> window.location='/'; </script>"
			
			session[:user] = params[:user]
		end
		
		def go_home
			return redirect_to "/"
		end
	
end
