# Go to Last.fm Auth page
get '/login/lastfm' do
  redirect lastfm_auth_url
end

# Callback from Last.fm auth
get '/auth/lastfm' do
  token = params[:token]
  user = User.find(session[:user_id])
  user.update(:lastfm_key => user.lastfm.auth.get_session(token: token)['key'])
  redirect '/'
end

# Go to Soundcloud auth page
get '/login/soundcloud' do
  redirect soundcloud_auth_url
end

# Callback from Soundcloud auth
get '/auth/soundcloud' do
  user = User.find(session[:user_id])
  client = soundcloud_client
  access_token = client.exchange_token(:code => params['code'])
  user.update(:soundcloud_key => access_token.access_token)
  redirect '/'
end

# Get Login Page
get '/login' do
  erb :login
end

# Create new session
post '/login' do
  @user = User.find_by(email: params[:email])
  if @user && @user.authenticate(params[:password])
    session[:user_id] = @user.id
    erb :'partials/_step2', :layout => false
  else
    "Invalid email or password"
  end
end

# Delete current session
delete '/signout' do
  session.clear
  redirect '/'
end