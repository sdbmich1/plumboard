class CreateCurrencyTypes < ActiveRecord::Migration
  def change
    create_table :currency_types do |t|
      t.string :code
      t.string :status
      t.string :hide
      t.string :description

      t.timestamps
    end
    add_index :currency_types, :code
  end
end
