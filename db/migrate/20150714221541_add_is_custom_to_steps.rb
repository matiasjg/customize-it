class AddIsCustomToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :is_custom, :boolean
  end
end
