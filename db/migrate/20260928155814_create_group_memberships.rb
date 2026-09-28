class CreateGroupMemberships < ActiveRecord::Migration[8.1]
  def change
    # Who is in a group; last_read_message_id tracks what each member has seen
    create_table :group_memberships do |t|
      t.references :conversation, null: false, foreign_key: { to_table: :group_conversations }
      t.references :user, null: false, foreign_key: true
      t.bigint :last_read_message_id

      t.timestamps
    end
    add_index :group_memberships, [ :conversation_id, :user_id ], unique: true
  end
end
