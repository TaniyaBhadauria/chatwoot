class AddStatusToAIAgentAssistantResponses < ActiveRecord::Migration[7.0]
  def change
    add_column :aiagent_assistant_responses, :status, :integer, default: 1, null: false
    add_index :aiagent_assistant_responses, :status
  end
end
