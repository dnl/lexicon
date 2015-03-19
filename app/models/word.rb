class Word < ActiveRecord::Base

    NUMBERS = [:singular, :plural]


  include Noun
  include Verb
  include Preposition
  include Adjective

  CLASSES = [
    :adjective,
    :article,
    :noun,
    :letter,
    :preposition,
    :pronoun,
    :verb
  ]

  belongs_to :dictionary
  validates :dictionary_id, presence: true
  validates :lexical_form, presence: true, length: {minimum:1}
  delegate :user, to: :dictionary
  has_many :tests, dependent: :destroy

  def display_word_class
    return word_class if word_class.present?
    return :preposition if preposition?
    return :adjective if adjective?
    return :noun if noun?
    return :verb if verb?
  end

  def word_class
    read_attribute(:word_class).to_sym if read_attribute(:word_class).present?
  end

  def lexical_form=(entry)
    word, translation = Word.split_lexical_form(entry)
    write_attribute(:translation, translation) if translation.present?
    write_attribute(:lexical_form, word)
    entry
  end

  def lexical_form
    read_attribute(:lexical_form) || ''
  end

  def term
    term ||= lexical_form.strip.match(PREPOSITION_RE).try(:[], :term) if preposition?
    term ||= lexical_form.strip.match(NOUN_RE).try(:[], :term) if nounish?
    term ||= lexical_form.strip.match(ADJECTIVE_RE).try(:[], :term) if adjective?
    term ||= lexical_form.strip
  end

  def lexical_tail
    return preposition_lexical_tail if preposition?
    return noun_lexical_tail if nounish?
    return adjective_lexical_tail if adjective?
  end

  def self.split_lexical_form(lexical_form)
    if lexical_form.include?("|")
      lexical_form.strip.split(/\s*\|\s*/)
    else
      lexical_form.strip
    end
  end

  def self.import(dictionary_id, words)
    words.each_line do |line|
      next if line.starts_with?('#') #it's a comment
      entry, translation = split_lexical_form(line.strip)
      unless where(lexical_form:entry, dictionary_id: dictionary_id).exists?
        #only modify new things.
        create(lexical_form: line.strip, dictionary_id: dictionary_id)
      end
    end
  end

  def stem
    @stem ||=
    case display_word_class
    when :noun, :pronoun
      noun_stem
    when :verb
      verb_stem
    else
      term
    end
  end

  #accents were futzing with sorting.
  def sort_term
    term.mb_chars.downcase.gsub(/[ἀἁᾀᾁ]/, 'α')
                          .gsub(/[ἐἑ]/,   'ε')
                          .gsub(/[ἠἡᾐᾑ]/, 'η')
                          .gsub(/[ἰἱ]/,   'ι')
                          .gsub(/[ὀὁ]/,   'ο')
                          .gsub(/[ὐὑ]/,   'υ')
                          .gsub(/[ὠὡᾠᾡ]/, 'ω')
  end

  ######

  def options(answer_method)
    case answer_method.to_sym
    when :word_class, :display_word_class
      CLASSES.map(&:to_s)
    when :takes_case, :display_takes_case
      ['accusative', 'genitive', 'dative']
    when :translation
      dictionary_test_options(answer_method)
    end
  end

  def dictionary_test_options(answer_method)
    options = Word
              .where(dictionary_id:dictionary_id)
              .where.not(id:id)
              .where(word_class:self.word_class)
              .limit(dictionary.valid_option_count)
    options.to_a.map(&answer_method.to_sym)
    .tap { |a| a << self.send(answer_method.to_sym) }
    .shuffle
  end

  def test_type
    dictionary.test_types.reject do |test_type|
      send(test_type.first).blank? ||
      send(test_type.last).blank?
    end.sample
  end

  def ending(variant)
    return noun_ending(variant) if nounish?
    return verb_ending(variant) if verb?
  end

end
