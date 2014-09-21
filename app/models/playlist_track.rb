class PlaylistTrack < ActiveRecord::Base
  belongs_to :track
  belongs_to :playlist

  validates_presence_of :track_id
  validates_presence_of :playlist_id
end
