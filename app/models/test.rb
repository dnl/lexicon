class Test < ActiveRecord::Base
  belongs_to :word
  belongs_to :dictionary
  delegate :user, to: :dictionary

  TEST_TYPES = [
    #question,       #answer
    [:word,          :pronunciation],
    [:word,          :translation],
    [:pronunciation, :word],
    [:translation,   :word],
    [:word_upcase,   :translation],
    [:word_upcase,   :word],
    [:word_upcase,   :pronunciation]
  ]
  TEST_TYPE_IDS = (0..TEST_TYPES.length-1).to_a

  def self.generate(dictionary)
    test_type = TEST_TYPES[dictionary.test_type_ids.sample]
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
    self.correct = is_answer?(answer)
    write_attribute(:given_answer, answer)
  end

  def is_answer?(answer)
    correct_answer.unicode_normalize == answer.unicode_normalize
  end
end
