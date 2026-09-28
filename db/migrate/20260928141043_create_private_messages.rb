class CreatePrivateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :private_messages do |t|
      t.text :body
      t.references :user, null: false, foreign_key: true
      t.references :conversation, null: false, foreign_key: { to_table: :private_conversations }
      t.boolean :seen, default: false, null: false

      t.timestamps
    end
  end
end
