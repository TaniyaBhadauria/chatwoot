class CreateAIAgentInbox < ActiveRecord::Migration[7.0]
  def change
    create_table :aiagent_inboxes do |t|
      t.references :aiagent_assistant, null: false
      t.references :inbox, null: false
      t.timestamps
    end

    add_index :aiagent_inboxes, [:aiagent_assistant_id, :inbox_id], unique: true
  end
end
