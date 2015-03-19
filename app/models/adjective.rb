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

  def adjectiveish?
    adjective? || article?
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

end