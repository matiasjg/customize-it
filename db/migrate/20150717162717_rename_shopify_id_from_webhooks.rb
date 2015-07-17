class RenameShopifyIdFromWebhooks < ActiveRecord::Migration
  def change
    rename_column :webhook_calls, :shopify_id, :order_id
  end
end
