class CreatePlaylistTracks < ActiveRecord::Migration
  def change
    create_table :playlist_tracks do |t|
      t.belongs_to :track
      t.belongs_to :playlist
      t.timestamps
    end
  end
end
