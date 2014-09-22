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
  @playlist.to_json :include => :tracks
end

# Go to playlist page
get '/playlists/:playlist_id' do
  @playlist = Playlist.find(params[:playlist_id])
  @playlist.to_json :include => :tracks
end

# Update Last.fm Now Playing
post '/lastfm/nowplaying' do
  params = JSON.parse(request.env["rack.input"].read)
  response = current_user.now_playing(artist: params['artist'], track: params['title'])
  response.to_json
end

# Scrobble finished track
post '/lastfm/scrobble' do
  params = JSON.parse(request.env["rack.input"].read)
  response = current_user.scrobble(artist: params['artist'], track: params['title'])
  response.to_json
end
