Rails.application.config.middleware.use OmniAuth::Builder do
	# First of all get a ca-bundle.crt file (eg : from your open-source browser package)
	require "openid/fetchers"
	OpenID.fetcher.ca_file = "#{Rails.root}/config/ca-bundle.crt"
	
	provider :openid, nil, :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
end