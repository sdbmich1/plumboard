class CreateMessageTypes < ActiveRecord::Migration
  def change
    create_table :message_types do |t|
      t.string :code
      t.string :description
      t.string :recipient
      t.string :status

      t.timestamps null: false
    end
  end
end
