class AddNextStepToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :next_step_id, :integer
  end
end
