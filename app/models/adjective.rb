module Adjective

  ADJECTIVE_RE = /^(?<term>[\p{Greek}'’\/\s]+),\s+
    (?:(?<feminine_declension_hint>[\p{Greek}'’]+),\s+)?
    (?<neuter_declension_hint>[\p{Greek}'’]+)\s*
  $/x

  def article?
    return read_attribute(:word_class).try(:to_sym) == :article
  end

  def adjective?
    return read_attribute(:word_class) == :adjective if read_attribute(:word_class).present?
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
      if ending_group
        Noun::NOUN_ENDINGS[ending_group].try(:[], Noun::NOUN_VARIANTS.index(variant))
      end
    end
  end

  def adjectiveish?
    adjective? || article?
  end

  def adjective_212?
    term[-2,2] == 'ος' &&
    neuter_declension_hint == 'ον' && (feminine_declension_hint == 'η' ||
                                       feminine_declension_hint == 'α')
  end

  def adjective_stem
    return term[0..-3] if adjective_212?
    term
  end

  def regular_adjective?
    adjective_212?
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


  # neuter is unadorned
  Noun::NOUN_VARIANTS.each do |variant|
    Noun::GENDERS.each do |gender|
      define_method(:"display_#{gender}_#{variant}") do
        return send(:"#{gender}_#{variant}") if send(:"#{gender}_#{variant}").present?
        return stem + adjective_ending(variant, gender) if regular_adjective? && adjective_ending(variant, gender)
      end
    end
    define_method(:"display_#{variant}") do
      send(:"display_neuter_#{variant}")
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