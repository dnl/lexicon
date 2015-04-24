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
    read_attribute(:lexical_form).try(:strip) || ''
  end

  def term
    return preposition_term if preposition?
    return noun_term if nounish?
    return adjective_term if adjective?
    return lexical_form
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

  def weight
    return 5 if incorrect.zero? && correct.zero?
    return incorrect if correct.zero?
    return 0.05 if incorrect.zero?
    return incorrect.to_f / correct.to_f
  end

  def stem
    @stem ||=
    case display_word_class
    when :noun, :pronoun
      noun_stem
    when :verb
      verb_stem
    when :adjective
      adjective_stem
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

  def variants
    return Noun::NOUN_VARIANTS if nounish?
    return Verb::VERB_VARIANTS if verb?
    return Adjective::ADJECTIVE_VARIANTS if adjectivish?
    return []
  end

  def variant_columns
    return Noun::NOUN_VARIANT_COLUMNS if nounish?
    return Verb::VERB_VARIANT_COLUMNS if verb?
    return Adjective::ADJECTIVE_VARIANT_COLUMNS if adjectivish?
    return []
  end

  def variant_combinations
    return Noun::NOUN_VARIANT_COMBINATIONS if nounish?
    return Verb::VERB_VARIANT_COMBINATIONS if verb?
    return Adjective::ADJECTIVE_VARIANT_COMBINATIONS if adjectivish?
    return []
  end

  def variants_with_answer(answer_method)
    column_index = variant_columns.index(answer_method)
    return [] unless column_index
    answers = variant_combinations.map { |v| v[column_index] }
    variants.map{|v|:"display_#{v}"}.zip(answers)
  end

  def options(answer_method)
    case answer_method.to_sym
    when :word_class, :display_word_class
      CLASSES.map(&:to_s)
    when :takes_case, :display_takes_case
      Preposition::PREPOSITION_CASES.map(&:to_s)
    when :case, *Noun::CASES
      Noun::CASES.map(&:to_s)
    when *Verb::PERSONS
      Verb::PERSONS.map(&:to_s)
    when :display_gender, *Noun::GENDERS
      Noun::GENDERS.map(&:to_s)
    when :number, *Word::NUMBERS
      Word::NUMBERS.map(&:to_s)
    when :translation
      dictionary_test_options(answer_method)
    end
  end

  def dictionary_test_options(answer_method)
    options = Word
              .where(dictionary_id:dictionary_id)
              .where.not(id:id)
              .limit(dictionary.valid_option_count)
              .order('RANDOM()')
              #.where(word_class:self.word_class)
    options.to_a.map(&answer_method.to_sym)
    .tap { |a| a << self.send(answer_method.to_sym) }
    .shuffle
  end

  def expanded_test_types
    variant_types = []
    dictionary.test_types.reject do |test_type|
      if test_type.first == :term_variant
        if variant_columns.include?(test_type.last)
          variant_types += variants_with_answer(test_type.last)
        else
          variant_types += variants.map {|v| [v, test_type.last] }
        end
        true
      else
        false
      end
    end + variant_types
  end

  def test_types
    expanded_test_types.reject do |test_type|
      method_or_symbol(test_type.first).to_s.blank? ||
      method_or_symbol(test_type.last ).to_s.blank?
    end
  end

  def test_type
    test_types.sample
  end

  def ending(variant)
    return noun_ending(variant) if nounish?
    return verb_ending(variant) if verb?
  end

  def method_or_symbol(symbol)
    return send(symbol) if self.respond_to?(symbol)
    return symbol
  end

  def regular?
    return regular_noun? if nounish?
    return regular_verb? if verb?
    return regular_adjective? if adjectivish?
    return regular_preposition? if preposition?
    return false
  end

  def self.orthograph word
    word.gsub(/ς/,  'σ')
        .gsub(/κσ/, 'ξ')
        .gsub(/πσ/, 'ψ')
        .gsub(/σ$/, 'ς')
  end

  def self.search params
    params = params.symbolize_keys.to_h
    word_class = params.delete(:word_class)
    regular = params.delete(:regular)
    id = params.delete(:word_id)
    params[:id] = id if id
    output = where(params).to_a
    output = output.select{|w| w.display_word_class == word_class.to_sym } if word_class.present?
    output = output.select{|w| w.regular?.to_s == regular } if regular.present?
    output
  end

end
