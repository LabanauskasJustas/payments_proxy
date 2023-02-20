class AddCancelledAtToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :cancelled_at, :datetime
    add_index :orders, :cancelled_at
  end
end
