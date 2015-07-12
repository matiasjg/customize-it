class AddPaymentTypeToShop < ActiveRecord::Migration
  def change
    add_column :shops, :payment_type, :string
  end
end
