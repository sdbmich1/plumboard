class CreateJobTypes < ActiveRecord::Migration
  def change
    create_table :job_types do |t|
      t.string :code
      t.string :job_name
      t.string :status

      t.timestamps
    end
    add_index :job_types, :code
  end
end
