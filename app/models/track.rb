require 'pry'

class Track < ActiveRecord::Base
  has_many :playlist_tracks
  has_many :playlists, :through => :playlist_tracks

  def get_soundcloud_uri
    retries = 2
    begin
      sc_tracks = sc_search
    rescue
      if retries > 0
        retries -= 1
        sleep 1
        retry
      else
        return false
      end
    end
    get_sc_top_track(sc_tracks)
  end

  def get_sc_top_track(track_list)
    track_list.reject! {|track| track.playback_count.nil? }
    top_track = track_list.sort_by {|track| track.playback_count}.reverse.first
    if top_track
      update(sc_uri: top_track['uri'])
      return true
    else
      return false
    end
  end

  def sc_search
    soundcloud_client.get(
      '/tracks',
      :q => "#{artist} #{title}",
      :limit=>20,
      :duration => {:from => 120000, :to => 600000},
      :streamable => true,
    )
  end

  def soundcloud_client
    SoundCloud.new({
      :client_id     => SOUNDCLOUD['client_id'],
      :client_secret => SOUNDCLOUD['client_secret'],
    })
  end
end
