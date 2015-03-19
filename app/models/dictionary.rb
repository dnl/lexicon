class Dictionary < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true
  validates :name, presence: true
  validates :name, uniqueness: {scope: :user_id}
  has_many :words, dependent: :destroy
  has_many :tests, dependent: :destroy

  def test_type_ids
    Test::TEST_TYPE_IDS - exclude_test_types
  end

  def test_type_ids=(test_type_ids)
    self.exclude_test_types = Test::TEST_TYPE_IDS - test_type_ids.map(&:to_i)
  end

  def test_types
    Test::TEST_TYPES.values_at(*test_type_ids)
  end

  def test_method_ids
    Test::TEST_METHOD_IDS - exclude_test_method_ids
  end

  def test_method_ids=(test_method_ids)
    self.exclude_test_method_ids = Test::TEST_METHOD_IDS - test_method_ids.map(&:to_i)
  end

  def test_missing_letters?
    test_method_ids.include? Test::TEST_METHODS.index(:missing_letters)
  end

  def test_select_option?
    test_method_ids.include? Test::TEST_METHODS.index(:select_option)
  end

  def test_word
    words.select('*, ( correct + 1) / (incorrect + 1 ) as ratio').order('ratio').limit(10).sample
  end

  def import(words)
    Word.import(self.id, words)
  end

  def valid_option_count
    rand(select_option_from..select_option_to)
  end

  def label_for_column column
    case column.to_sym
    when :word
      word_column_label
    when :word_upcase
      I18n.t 'label.word_upcase', word: word_column_label
    when :translation
      translation_column_label
    else
      I18n.t "label.#{column}"
    end
  end
end
