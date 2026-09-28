class CreatePrivateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :private_conversations do |t|
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :sender, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :private_conversations, [ :recipient_id, :sender_id ], unique: true
  end
end
