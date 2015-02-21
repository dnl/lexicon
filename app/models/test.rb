class Test < ActiveRecord::Base
  belongs_to :word
  belongs_to :dictionary
  delegate :user, to: :dictionary
  after_save :update_word_test_count

  TEST_TYPES = [
    #question,       #answer
    [:word,          :pronunciation],
    [:word,          :translation],
    [:pronunciation, :word],
    [:translation,   :word],
    [:word_upcase,   :translation],
    [:word_upcase,   :word],
    [:word_upcase,   :pronunciation],
    [:translation,   :word_upcase],
    [:pronunciation, :word_upcase],
    [:word,          :word_upcase],
    [:word,          :property],
    [:word,          :variant_key],
    [:variant_key,   :word]
  ]

  TEST_METHODS = [
    # :missing_letters,
    :select_option
  ]

  TEST_TYPE_IDS = (0..TEST_TYPES.length-1).to_a
  TEST_METHOD_IDS = (0..TEST_METHODS.length-1).to_a

  def self.generate(dictionary, attempts=0)
    raise ActiveRecord::RecordNotFound if attempts > 10
    test_type = TEST_TYPES[dictionary.test_type_ids.sample]
    test_word = dictionary.test_word
    test_method_id = dictionary.test_method_ids.sample
    test_method = TEST_METHODS[test_method_id]
    test_type = valid_test_type(dictionary, test_word, test_method)

    return generate(dictionary, attempts+1) if test_type.nil?
    only_variants = test_type.include?(:variant)
    question_column, answer_column = test_type

    options = case test_method
    when :select_option
     test_word.options(answer_column, only_variants)
    when :missing_letters
      [test_word.missing_letters(answer_column)]
    end

    correct_answer = case answer_column
    when :property
      test_word.property_included_in(options)
    else
      test_word.send(answer_column)
    end

    create(
      dictionary: dictionary,
      word: test_word,
      test_method_id: test_method_id,
      question: test_word.send(question_column),
      correct_answer: correct_answer,
      options: options,
      question_method: question_column,
      answer_method: answer_column
    )
  end

  def update_word_test_count
    return true if self.correct.nil?
    Word.where(id:self.word_id)
        .first
        .increment!(self.correct? ? :correct : :incorrect)
    return true
  end

  def self.valid_test_type(dictionary, word, test_method)
    dictionary.test_types.reject do |test_type|
      (test_method == :missing_letters &&
       Test.map_columns(test_type.last) != :word) ||
      word.send(Test.map_columns(test_type.first)).blank? ||
      word.send(Test.map_columns(test_type.last)).blank?
    end.sample
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

  def self.map_columns column
    case column.to_sym
    when :word_upcase, :word_downcase
      :word
    when :variant_key
      :variant
    when :property
      :properties
    else
      column
    end
  end

end
