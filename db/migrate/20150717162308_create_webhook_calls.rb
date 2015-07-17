class CreateWebhookCalls < ActiveRecord::Migration
  def change
    create_table :webhook_calls do |t|
      t.integer :shopify_id

      t.timestamps null: false
    end
  end
end
