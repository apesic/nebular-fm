class Track < ActiveRecord::Base
  has_many :playlist_tracks
  has_many :playlists, :through => :playlist_tracks

  def get_soundcloud_uri
    client = soundcloud_client
    query = "#{self.artist} #{self.title}"
    sc_tracks = client.get(
      '/tracks',
      :q => query,
      :limit=>20,
      :duration => {:from => 120000, :to => 600000},
      :streamable => true,
    )
    sc_tracks.reject! {|track| track.playback_count.nil? }
    top_track = sc_tracks.sort_by {|track| track.playback_count}.reverse.first
    if top_track
      self.update(sc_uri: top_track['uri'])
      return true
    else
      return false
    end
  end

  def soundcloud_client
    SoundCloud.new({
      :client_id     => SOUNDCLOUD['client_id'],
      :client_secret => SOUNDCLOUD['client_secret'],
    })
  end
end
