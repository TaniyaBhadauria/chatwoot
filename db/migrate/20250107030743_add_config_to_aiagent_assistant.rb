class AddConfigToAIAgentAssistant < ActiveRecord::Migration[7.0]
  def change
    add_column :aiagent_assistants, :config, :jsonb, default: {}, null: false
  end
end
