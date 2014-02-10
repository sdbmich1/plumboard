class CreateFaqs < ActiveRecord::Migration
  def change
    create_table :faqs do |t|
      t.string :subject
      t.text :description
      t.string :status
      t.string :question_type

      t.timestamps
    end
  end
end
