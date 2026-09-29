class AddOmniauthToUsers < ActiveRecord::Migration[8.1]
  def change
    # The login provider ("google_oauth2") and the user's id there, for users who log in with Google
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_index :users, [ :provider, :uid ], unique: true
  end
end
