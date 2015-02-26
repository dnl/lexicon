class Word < ActiveRecord::Base

  CASES = [:nominative, :vocative, :accusative, :genitive, :dative]
  COMMON_CASES = [:nominative, :accusative, :genitive, :dative]
  PLURALITIES = [:singular, :plural]
  PERSONS = [:first_person, :second_person, :third_person]

  GENDERS = [:masculine, :feminine, :neuter]
  DECLENSIONS = [:first_declension, :second_declension, :third_declension]
  TENSES = [:present] #more to come

  ARTICLE_VARIANTS = { gender: GENDERS, plurality: PLURALITIES, case: COMMON_CASES }
  VERB_VARIANTS = { plurality: PLURALITIES, person: PERSONS, tense: TENSES }
  NOUN_VARIANTS = { plurality: PLURALITIES, case: CASES }
  NOUN_PROPERTIES = { gender: GENDERS } #later: , declension: DECLENSIONS
  PREPOSITION_PROPERTIES = { takes: COMMON_CASES }

  CLASSES = {
    article: {variants: ARTICLE_VARIANTS},
    noun: {properties: NOUN_PROPERTIES, variants: NOUN_VARIANTS},
    preposition: {properties: PREPOSITION_PROPERTIES},
    verb: {variants: VERB_VARIANTS},
    letter: {}
  }

  belongs_to :dictionary
  validates :dictionary_id, presence: true
  validates :word, presence: true
  delegate :user, to: :dictionary
  has_many :tests, dependent: :destroy
  belongs_to :root, class_name: Word
  has_many :variants, class_name: Word, foreign_key: :root_id, dependent: :destroy

  accepts_nested_attributes_for :variants, reject_if: proc {|attributes| attributes[:word].blank? }

  before_validation :remove_invalid_properties_variant
  before_validation :set_properties_from_root
  before_validation :skip_blank_properties

  def self.testable(*has_columns)
    order('RANDOM()').tap do |words|
      has_columns.each do |has_column|
        words = words.where.not(Test.map_columns(has_column) => nil)
      end
    end
  end

  def remove_invalid_properties_variant
    if self.word_class_changed?
      self.properties = nil unless self.properties_changed?
      self.variant = nil unless variant_keys(true).include?(self.variant)
    end
    return true
  end

  def skip_blank_properties
    self.properties = self.properties.select(&:present?) if self.properties.present?
    return true
  end

  def set_properties_from_root
    unless is_root?
      self.word_class = root.word_class
      self.properties = root.properties
      self.dictionary_id = root.dictionary_id
      self.translation = root.translation if self.translation.blank?
    end
    return true
  end

  def root
    return read_attribute(:root) if read_attribute(:root).present?
    return self if self.persisted? && self.is_root? #persisted so we don't get a loop
    return Word.find(self.root_id) if self.root_id
  end

  def root_id
    return read_attribute(:root_id) if read_attribute(:root_id).present?
    return self.id if self.persisted? && self.is_root?
  end

  def missing_letters(answer_column)
    word_missing_letters = send(answer_column).split(/\s*,\s*/).sample
    indexes = (0..(word_missing_letters.length - 1)).to_a
    to_miss = [word_missing_letters.length, dictionary.valid_missing_letters_count].min
    indexes.sample(to_miss).each do |index|
      word_missing_letters[index] = '*'
    end
    word_missing_letters
  end

  def options(answer_column, only_variants)
    case answer_column
    when :properties, :property
      property_test_options
    else
      dictionary_test_options(answer_column, only_variants)
    end
  end

  def variant_key
    variant.join('|') if variant.present?
  end

  def property_test_options
    property = properties.sample.to_sym
    property_options.values.find{|v| v.include?(property)}
  end

  def dictionary_test_options(answer_column, only_variants=false)
    options = Word.testable(answer_column)
              .where(dictionary_id:dictionary_id)
              .where.not(id:id)
              .where(word_class:self.word_class)
              .limit(dictionary.valid_option_count)
    if only_variants
      options = options.where(root_id:self.root_id)
    end
    options.to_a.map(&answer_column)
    .tap { |a| a << self.send(answer_column) }
    .shuffle
  end

  def self.variant(key)
    if key.blank?
      root_words
    else
      where("variant @> ARRAY[?]::varchar[]", key)
    end
  end

  def self.root_words
    where('words.root_id = words.id OR words.root_id IS NULL')
  end

  def variants_by_variant(include_root=false)
    variant_keys(include_root).map do |key|
      if self.root.try(:persisted?)
        [key,
         Word.where(root_id:self.root_id)
             .variant(key)
             .first_or_initialize(variant:key,word_class:word_class)]
      else
        [key, Word.new(variant:key,word_class:word_class,root:self.root)]
      end
    end.to_h
  end

  def variant
    read_attribute(:variant) ||
    (root_variant if is_root?)
  end

  def property_included_in options
    return nil if self.properties.blank?
    (self.properties & options.map(&:to_s)).first
  end

  def root_variant
    variant_keys(true).first
  end

  def property_options
    return [] unless word_class
    Word::CLASSES[word_class.to_sym][:properties] || []
  end

  def variant_keys(include_root=false)
    root_only = []
    return root_only unless word_class
    keys = Word::CLASSES[word_class.to_sym][:variants]
    return root_only unless keys
    first, *rest = keys.values
    keys = first.product(*rest)
    return keys if include_root
    return keys.drop(1)
  end

  def word_upcase
    word.mb_chars.upcase
  end

  def word_downcase
    word.mb_chars.downcase
  end

  def is_root?
    return self.read_attribute(:root_id) == self.id if self.root_id?
    return self.read_attribute(:root_id).nil? if self.persisted?
    return ((self.read_attribute(:variant) || []) - (self.root_variant || [])).blank?
  end

end
