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

# Scrobble current track
post '/lastfm/nowplaying/:track_id' do
  track = Track.find(params[:track_id])
  current_user.scrobble(track)
end

# Scrobble finished track
post '/lastfm/scrobble/:track_id' do
  track = Track.find(params[:track_id])
  current_user.scrobble(track)
end
