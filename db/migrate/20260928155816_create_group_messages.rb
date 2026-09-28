class CreateGroupMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :group_messages do |t|
      t.text :body
      t.references :user, null: false, foreign_key: true
      t.references :conversation, null: false, foreign_key: { to_table: :group_conversations }

      t.timestamps
    end
  end
end
