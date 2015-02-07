class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.belongs_to :word, null: false
      t.belongs_to :dictionary, null: false
      t.string :question, null: false
      t.string :correct_answer, null: false
      t.string :options, array: true
      t.string :given_answer
      t.boolean :correct
      t.timestamps null: false
    end
  end
end
