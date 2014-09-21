class Track < ActiveRecord::Base
  has_many :playlist_tracks
  has_many :playlists, :through => :playlist_tracks

  def get_soundcloud_uri
    client = soundcloud_client
    begin
      sc_tracks = client.get(
        '/tracks',
        :q => "#{artist} #{title}",
        :limit=>20,
        :duration => {:from => 120000, :to => 600000},
        :streamable => true,
      )
    rescue
      binding.pry
      return false
    end
    top_track = get_sc_top_track(sc_tracks)
    if top_track
      update(sc_uri: top_track['uri'])
      return true
    else
      return false
    end
  end

  def get_sc_top_track(track_list)
    track_list.reject! {|track| track.playback_count.nil? }
    return track_list.sort_by {|track| track.playback_count}.reverse.first
  end

  def soundcloud_client
    SoundCloud.new({
      :client_id     => SOUNDCLOUD['client_id'],
      :client_secret => SOUNDCLOUD['client_secret'],
    })
  end
end
