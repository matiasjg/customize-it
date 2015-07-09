class AddStepUrlToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :step_url, :string
  end
end
