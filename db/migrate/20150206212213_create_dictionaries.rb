class CreateDictionaries < ActiveRecord::Migration
  def change
    create_table :dictionaries do |t|
      t.belongs_to :user, index: true, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_foreign_key :dictionaries, :users
  end
end
