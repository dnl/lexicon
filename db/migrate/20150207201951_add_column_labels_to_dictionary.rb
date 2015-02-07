class AddColumnLabelsToDictionary < ActiveRecord::Migration
  def change
    add_column :dictionaries, :word_column_label, :string, default: 'Word', null: false
    add_column :dictionaries, :translation_column_label, :string, default: 'Translation', null: false
  end
end
