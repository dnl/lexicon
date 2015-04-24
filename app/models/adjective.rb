module Adjective

  ADJECTIVE_RE = /^(?<term>[\p{Greek}'’\/\s]+),\s+
    (?:(?<feminine_declension_hint>[\p{Greek}'’]+),\s+)?
    (?<neuter_declension_hint>[\p{Greek}'’]+)\s*
  $/x

  ADJECTIVE_VARIANT_COMBINATIONS = Noun::GENDERS.product(Noun::NOUN_VARIANT_COMBINATIONS).map(&:flatten)
  ADJECTIVE_VARIANTS = Adjective::ADJECTIVE_VARIANT_COMBINATIONS.map {|n| n.map(&:to_s).join('_').to_sym }
  ADJECTIVE_VARIANT_COLUMNS = [:gender, :number, :case]

  def article?
    word_class == :article
  end

  def adjective?
    return word_class == :adjective if word_class.present?
    !! lexical_form.match(ADJECTIVE_RE)
  end

  def adjective_ending(variant, gender)
    if adjective_212?
      if gender == :masculine
        ending_group = '2.1'
      elsif gender == :feminine
        if feminine_declension_hint == 'η'
          ending_group = '1.1'
        elsif feminine_declension_hint == 'α'
          ending_group = '1.2'
        end
      else
        ending_group = '2.3'
      end
    end

    if ending_group
      Noun::NOUN_ENDINGS[ending_group].try(:[], Noun::NOUN_VARIANTS.index(variant))
    end
  end

  def adjectiveish?
    adjective? || article?
  end

  def adjectivish?
    adjectiveish?
  end

  def adjective_212?
    term[-2,2] == 'ος' &&
    neuter_declension_hint == 'ον' && (feminine_declension_hint == 'η' ||
                                       feminine_declension_hint == 'α')
  end

  def adjective_33?
    feminine_declension_hint.blank? && neuter_declension_hint.present?
  end

  def adjective_stem
    return term[0..-3] if adjective_212?
    term
  end

  def regular_adjective?
    return false unless adjective_212?
    ADJECTIVE_VARIANTS.all? { |variant| send(variant).blank? }
  end

  def adjective_lexical_tail
    return ", #{neuter_declension_hint}" unless feminine_declension_hint.present?
    ", #{feminine_declension_hint}, #{neuter_declension_hint}"
  end

  def feminine_declension_hint
    return nil unless adjectiveish?
    lexical_form.match(ADJECTIVE_RE).try(:[], :feminine_declension_hint)
  end

  def neuter_declension_hint
    return nil unless adjectiveish?
    lexical_form.match(ADJECTIVE_RE).try(:[], :neuter_declension_hint)
  end

  def adjective_term
    lexical_form.match(ADJECTIVE_RE).try(:[], :term) || lexical_form
  end

  def adjective_from_lexical_form(gender)
    case gender
    when :masculine
      adjective_term
    when :neuter
      neuter_declension_hint
    when :feminine
      return adjective_term if adjective_33?
      return feminine_declension_hint
    end
  end

  # neuter is unadorned
  Noun::NOUN_VARIANTS.each do |variant|
    Noun::GENDERS.each do |gender|
      define_method(:"display_#{gender}_#{variant}") do
        return send(:"#{gender}_#{variant}") if send(:"#{gender}_#{variant}").present?
        return Word.orthograph(stem + adjective_ending(variant, gender)) if regular_adjective? && adjective_ending(variant, gender)
        return adjective_from_lexical_form(gender) if variant == :singular_nominative
      end
    end
    #can't alias_method as these are built after talking to the db.
    define_method(:"neuter_#{variant}=") do |value|
      send(:"#{variant}=", value)
    end
    define_method(:"neuter_#{variant}") do
      send(:"#{variant}")
    end
  end

end