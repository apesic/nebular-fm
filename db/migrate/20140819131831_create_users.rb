class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :lastfm_key
      t.string :soundcloud_key
      t.string :password_digest
      t.timestamps
    end
  end
end
