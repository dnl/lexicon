class Test < ActiveRecord::Base
  belongs_to :word
  belongs_to :dictionary
  delegate :user, to: :dictionary

  TEST_TYPES = [
    #question,       #answer
    [:word,          :pronunciation],
    [:word,          :translation],
    [:pronunciation, :word],
    [:translation,   :word]
  ]

  def self.generate(dictionary, test_type=TEST_TYPES.sample)
    test_word = Word.where(dictionary_id: dictionary.id)
                     .test_word(*test_type)
    question_column, answer_column = test_type
    create(
      dictionary: dictionary,
      word: test_word,
      question: test_word.send(question_column),
      correct_answer: test_word.send(answer_column),
      options: test_word.answers(answer_column),
      question_method: question_column,
      answer_method: answer_column
    )
  end

  def given_answer=(answer)
    self.correct = answer == correct_answer
    write_attribute(:given_answer, answer)
  end
end
