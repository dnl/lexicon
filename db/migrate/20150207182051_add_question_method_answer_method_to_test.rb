class AddQuestionMethodAnswerMethodToTest < ActiveRecord::Migration
  def change
    add_column :tests, :question_method, :string
    add_column :tests, :answer_method, :string
  end
end
