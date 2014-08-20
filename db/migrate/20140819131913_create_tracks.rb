class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.string :title
      t.string :artist
      t.string :tags
      t.string :sc_uri
    end
  end
end
