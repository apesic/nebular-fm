get '/' do
  erb :index
end

# Get signup page
get '/signup' do
  erb :signup
end

# Create new user
post '/signup' do
  @user = User.create(params[:signup])
  if @user.valid?
    session[:user_id] = @user.id
    erb :'partials/_step2', :layout => false
  else
    @user.errors.full_messages

  end
end

# Get playlist
post '/playlists/generate' do
  @playlist = Playlist.create(user_id: current_user.id)
  @playlist.generate
  @playlist.to_json :include => :tracks
end

# Go to playlist page
get '/playlists/:playlist_id' do
  @playlist = Playlist.find(params[:playlist_id])
  @playlist.to_json :include => :tracks
end

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
  p params
  access_token = client.exchange_token(:code => params['code'])
  p access_token
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

# TODO: Switch to delete method via ajax
# Delete current session
delete '/signout' do
  session.clear
  redirect '/'
end


post '/lastfm/nowplaying/:track_id' do
  track = Track.find(params[:track_id])
  current_user.scrobble(track)
end

post '/lastfm/scrobble/:track_id' do
  track = Track.find(params[:track_id])
  current_user.scrobble(track)
end

