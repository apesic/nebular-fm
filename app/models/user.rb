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

  def lastfm_rec_artists
    lastfm.user.get_recommended_artists(limit: 20)
  end

  def top_tracks(artist)
    lastfm.artist.get_top_tracks(artist: artist['name'], limit: 10)
  end
end
