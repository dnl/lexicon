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

  def label_for_column column

    case column.to_sym
    when :word
      word_column_label
    when :word_upcase
      I18n.t 'label.word_upcase', word: word_column_label
    when :translation
      translation_column_label
    when :pronunciation
      I18n.t 'label.pronunciation'
    end
  end
end
