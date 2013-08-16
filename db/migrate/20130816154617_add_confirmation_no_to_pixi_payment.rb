class AddConfirmationNoToPixiPayment < ActiveRecord::Migration
  def change
    add_column :pixi_payments, :confirmation_no, :string
    add_index :pixi_payments, :confirmation_no
  end
end
