class AddLexicalDataToWord < ActiveRecord::Migration
  def change
    add_column :words, :word_class, :string
    add_column :words, :properties, :string, array: true
    add_column :words, :variant, :string, array: true
    add_column :words, :root_id, :integer
    change_column :words, :translation, :string, null: true
  end
end