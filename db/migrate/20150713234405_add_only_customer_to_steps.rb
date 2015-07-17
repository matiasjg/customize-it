class AddOnlyCustomerToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :only_customer, :boolean
  end
end
