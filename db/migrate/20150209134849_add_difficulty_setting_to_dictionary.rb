class AddDifficultySettingToDictionary < ActiveRecord::Migration
  def change
    add_column :dictionaries, :select_option_from, :integer, null: true, default: 3
    add_column :dictionaries, :select_option_to, :integer, null: true, default: 5
    add_column :dictionaries, :exclude_test_method_ids, :integer, array: true, default: [], null: false
    add_column :dictionaries, :missing_letters_from, :integer, null: true, default: 1
    add_column :dictionaries, :missing_letters_to, :integer, null: true, default: 2
    add_column :tests, :test_method_id, :integer, null: false, default: Test::TEST_METHODS.index(:select_option)
  end
end
