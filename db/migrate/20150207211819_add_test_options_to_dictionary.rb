class AddTestOptionsToDictionary < ActiveRecord::Migration
  def change
    add_column :dictionaries, :exclude_test_types, :integer, array: true, default: []
  end
end
