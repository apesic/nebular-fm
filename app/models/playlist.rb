class Playlist < ActiveRecord::Base
  has_many :playlist_tracks
  has_many :tracks, :through => :playlist_tracks
  belongs_to :user

  validates :user_id, :presence => true

  def generate
    artists = self.user.lastfm_rec_artists#.sample(35)
    artists.each do |artist|
      top_track = self.user.top_tracks(artist).sample
      track = Track.find_or_initialize_by(title: top_track['name'], artist: artist['name'])

      if track && track.get_soundcloud_uri
        track.save!
        playlist_track = PlaylistTrack.new(
          track_id: track.id,
          playlist_id: self.id
        )
        playlist_track.save!
      end

    end
  end
end
