class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    # A contact request from user to contact; accepted once the contact agrees
    create_table :contacts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: { to_table: :users }
      t.boolean :accepted, default: false, null: false

      t.timestamps
    end
    add_index :contacts, [ :user_id, :contact_id ], unique: true
  end
end
