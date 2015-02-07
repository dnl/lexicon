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
        words = words.where.not(has_column => nil)
      end
    end
  end

  def self.test_word(*has_columns)
    self.testable(*has_columns).first
  end

  def answers(answer_column, options = 3)
    return [] if options.zero? || options.nil?
    Word.testable(answer_column)
    .where.not(id:id)
    .limit(options)
    .pluck(answer_column)
    .tap { |a| a << self.send(answer_column) }
    .shuffle
  end

end
