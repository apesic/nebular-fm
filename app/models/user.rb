class User < ActiveRecord::Base
  validates_presence_of :password, :on => :create
  has_secure_password

  has_many :playlists
  has_many :tracks, :through => :playlists

  def lastfm
    lastfm = Lastfm.new(LASTFM['api_key'], LASTFM['api_secret'])
    lastfm.session = self.lastfm_key
    return lastfm
  end

  def now_playing(track)
    lastfm.track.update_now_playing(artist: track.artist, track: track.title)

  end

  def scrobble(track)
    lastfm.track.scrobble(artist: track.artist, track: track.title)

  end

  def lastfm_rec_artists
    lastfm.user.get_recommended_artists(limit: 50)
  end

  def top_tracks(artist)
    lastfm.artist.get_top_tracks(artist: artist['name'], limit: 10)
  end
end
