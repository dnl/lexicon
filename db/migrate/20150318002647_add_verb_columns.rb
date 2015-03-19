class AddVerbColumns < ActiveRecord::Migration
  def change
    add_column :words, :singular_first, :string
    add_column :words, :singular_second, :string
    add_column :words, :singular_third, :string
    add_column :words, :plural_first, :string
    add_column :words, :plural_second, :string
    add_column :words, :plural_third, :string
    add_column :words, :future_singular_first, :string
    add_column :words, :future_singular_second, :string
    add_column :words, :future_singular_third, :string
    add_column :words, :future_plural_first, :string
    add_column :words, :future_plural_second, :string
    add_column :words, :future_plural_third, :string
  end
end
