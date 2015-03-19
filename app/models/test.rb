class Test < ActiveRecord::Base
  belongs_to :word
  belongs_to :dictionary
  delegate :user, to: :dictionary
  after_save :update_word_test_count

  TEST_TYPES = [
    #question,       #answer
    [:term_with_case_taken, :translation],
    [:term, :display_word_class],
    [:term, :display_takes_case]
  ]

  TEST_METHODS = []

  TEST_TYPE_IDS = (0..TEST_TYPES.length-1).to_a
  TEST_METHOD_IDS = (0..TEST_METHODS.length-1).to_a

  def self.generate(dictionary, params={}, attempts=0)
    raise ActiveRecord::RecordNotFound if attempts > 60
    test = Test.new(dictionary_id:dictionary.id)
    test.word = Word.where(id:params[:word_id]).first if params[:word_id].present?
    test.word ||= dictionary.test_word

    test.question_method, test.answer_method = test.word.test_type
    return generate(dictionary, params, attempts+1) if test.question_method.blank?

    test.options = test.word.options(test.answer_method)

    test.correct_answer = test.word.send(test.answer_method)
    test.question = test.word.send(test.question_method)
    test.save!
    test
  end

  def update_word_test_count
    return true if self.correct.nil?
    Word.where(id:self.word_id)
        .first
        .increment!(self.correct? ? :correct : :incorrect)
    return true
  end

  def given_answer=(answer)
    self.correct = is_answer?(answer)
    write_attribute(:given_answer, answer)
  end

  def given_answer_array=(answer)
    self.given_answer = answer.join
  end

  def is_answer?(answer)
    Test.normalize(correct_answer).split(/\s*,\s*/).include?(Test.normalize(answer))
  end

  def test_method
    TEST_METHODS[test_method_id]
  end

  def self.normalize word
    word.unicode_normalize.mb_chars.downcase
  end

end
