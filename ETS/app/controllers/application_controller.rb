class ApplicationController < ActionController::Base
  protect_from_forgery :except => :auth
  
  before_filter :set_locale
  
  def set_locale # Set locale/dictionary from .\config\locales
	if !params[:locale].nil?
		I18n.locale = params[:locale]
	else if !session[:locale].nil?
			I18n.locale = session[:locale]
		else
			I18n.locale = 'pt-BR' # Fallback is pt-BR
		end
	end
	session[:locale] = I18n.locale.to_s
  end
  
  #helper_method :current_user
  helper_method :user_signed_in?
  helper_method :auth_session
  #helper_method :del_user_sessions
  helper_method :user_name
  helper_method :user_id
  #helper_method :uid
  #helper_method :provider

  private  
    #def current_user
    #  @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
    #end
    
    def user_signed_in?
	  return 1 if auth_session
    end
      
    def authenticate_user!
      if !user_signed_in?
        flash[:error] = t(:msg_unauth)
        redirect_to root_path
      end
    end
	
	def auth_session
		session[:omniauth]
	end
	
	#def del_user_sessions
	#	session[:omniauth] = nil
	#	session.delete :omniauth
	#end
	
	def user_name
		# if provider == 'google'
		auth_session['user_info']['name']
	end
	
	def user_id
		# if provider == 'google'
		auth_session['user_info']['email']
	end
	
	#def uid
		# if provider == 'google'
	#	auth_session['uid'].to_s
	#end
	
	#def provider
	#	auth_session['provider']
	#end
end
