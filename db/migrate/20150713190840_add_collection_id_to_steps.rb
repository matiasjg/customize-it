class AddCollectionIdToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :collection_id, :string
  end
end
