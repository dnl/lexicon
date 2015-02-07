class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :word, null: false
      t.string :translation, null: false
      t.string :pronunciation
      t.integer :ability
      t.references :dictionary
      t.timestamps null: false
    end
    add_foreign_key :words, :dictionaries
  end
end
