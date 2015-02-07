class AddCurrentDictionaryToUser < ActiveRecord::Migration
  def change
    add_column :users, :current_dictionary_id, :integer
  end
end
