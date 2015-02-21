class AbilityToRatio < ActiveRecord::Migration
  def up
    remove_column :words, :ability
    add_column :words, :correct, :integer, null: false, default: 0
    add_column :words, :incorrect, :integer, null: false, default: 0
    Word.find_each do |word|
      word.correct = Test.where(word_id:word.id, correct:true).count
      word.incorrect = Test.where(word_id:word.id, correct:false).count
      word.save!
    end
  end
  def down
    add_column :words, :ability, :integer
    remove_column :words, :correct
    remove_column :words, :incorrect
  end
end
