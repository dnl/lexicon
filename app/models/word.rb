class Word < ActiveRecord::Base

  belongs_to :dictionary
  validates :dictionary, presence: true
  validates :word, presence: true
  validates :translation, presence: true
  delegate :user, to: :dictionary
  has_many :tests, dependent: :destroy

  def self.testable(*has_columns)
    order('RANDOM()').tap do |words|
      has_columns.each do |has_column|
        words = words.where.not(map_test_column(has_column) => nil)
      end
    end
  end

  def self.test_word(*has_columns)
    self.testable(*has_columns).first
  end

  def answers(answer_column, options = 3)
    return [] if options.zero? || options.nil?
    Word.testable(answer_column)
    .where(dictionary_id:dictionary_id)
    .where.not(id:id)
    .limit(options)
    .to_a.map(&answer_column)
    .tap { |a| a << self.send(answer_column) }
    .shuffle
  end

  def word_upcase
    word.mb_chars.upcase
  end

  def word_downcase
    word.mb_chars.downcase
  end

  def self.map_test_column column
    case column.to_sym
    when :word_upcase, :word_downcase
      :word
    else
      column
    end
  end

end
