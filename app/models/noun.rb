module Noun

  CASES = [:nominative, :vocative, :accusative, :genitive, :dative]
  NOUN_RE = /^(?<term>[\p{Greek}'’\/\s]+)
              (?:,\s
                (?:(?<declension_hint>[\p{Greek}'’]+)\s)?
              |\s)
              (?<gender>[mfn])
            /x

  NOUN_VARIANTS = Word::NUMBERS.product(CASES)
                               .map {|n| n.map(&:to_s).join('_').to_sym }
                               .reject { |w| w == :plural_vocative}

  GENDERS = [
    :masculine,
    :feminine,
    :neuter
  ]

  NOUN_ENDINGS = {
             #Nom  Voc  Acc   Gen   Dat  pNom   pAcc   pGen   pDat
    '1.1' => ['η', nil, 'ην', 'ης', 'ῃ', 'αι',  'ας',  'ων',  'αις'], #!LEARN!
    '1.2' => ['α', nil, 'αν', 'ας', 'ᾳ', 'αι',  'ας',  'ων',  'αις'],
    '1.3' => ['α', nil, 'αν', 'ης', 'ῃ', 'αι',  'ας',  'ων',  'αις'],
    '1.4' => ['ης','α', 'ην', 'ου', 'ῃ', 'αι',  'ας',  'ων',  'αις'],
    '1.5' => ['ας','α', 'αν', 'ου', 'ᾳ', 'αι',  'ας',  'ων',  'αις'],
    '1.6' => ['ας','α', 'αν', 'α',  'ᾳ'],
    '2.1' => ['ος','ε', 'ον', 'ου', 'ῳ', 'οι',  'ους', 'ων',  'οις'], #!LEARN!
    '2.2' => ['ς', '',  'ν',  '',   '' ],
    '2.3' => ['ον',nil, 'ον', 'ου', 'ῳ', 'α',   'α',   'ων',  'οις'], #!LEARN!
    '3.1' => ['ς', nil, 'δα', 'δος','δι','δες', 'δας', 'δων', 'σιν'],
    '3.2' => ['ηρ','ερ','ερα','ρος','ρι','ερες','ερας','ερων','ρασιν'],
    '3.3' => ['ς', '',  'ν',  'ος', 'ι', 'ες',  'ας',  'ων',  'σιν'],
    '3.4' => ['ις','ι', 'ιν', 'εως','ει','εις', 'εις', 'εων', 'εσιν'],
    '3.5' => ['υς','υ', 'α',  'ως', 'ι', 'ις',  'ις',  'ων',  'υσιν'],
    '3.6' => ['',  nil, '',   'τος','τι','τα',  'τα',  'των', 'σιν'],
    '3.7' => ['ος',nil, 'ος', 'ους','ει','η',   'η',   'ων',  'εσιν']
  }

  def noun_ending(variant)
    NOUN_ENDINGS[self.declension].try(:[], NOUN_VARIANTS.index(variant))
  end

  def regular_noun?
    return false unless nounish? && declension
    NOUN_VARIANTS.all? { |variant| send(variant).blank? }
  end

  def noun?
    return read_attribute(:word_class).to_sym == :noun if read_attribute(:word_class).present?
    !! lexical_form.match(NOUN_RE)
  end

  def pronoun?
    return read_attribute(:word_class).try(:to_sym) == :pronoun
  end

  def declension_hint
    return unless nounish?
    lexical_form.match(NOUN_RE).try(:[], :declension_hint)
  end

  def gender
    return unless nounish?
    @gender ||= lexical_form.match(NOUN_RE).try(:[], :gender).try(:to_sym)
  end

  def nounish?
    noun? || pronoun?
  end

  def noun_lexical_tail
    ", #{declension_hint} #{gender}" if declension_hint.present?
  end

  ###

  def noun_declension
    @declension ||= case declension_hint
    when 'ης'
      case term.last
      when 'η' then '1.1'
      when 'υ' then '1.3'
      end
    when 'ας' then '1.2'
    when 'ου'
      case term[-2,2]
      when 'ης' then '1.4'
      when 'ας' then '1.5'
      when 'ος' then '2.1'
      when 'υς' then '2.2'
      when 'ον' then '2.3'
      end
    when 'α' then '1.6'
    when 'ιδος' then '3.1'
    when 'τρος' then '3.2'
    when 'υος' then '3.3'
    when 'εως'
      case gender
      when :f then '3.4'
      when :m then '3.5'
      end
    when 'τος' then '3.6'
    when 'oυς' then '3.7'
    end
  end

  def declension
    noun_declension
  end

  def noun_term
    lexical_form.match(NOUN_RE).try(:[], :term) || lexical_form
  end

  def noun_stem
    case self.declension
    when '3.6'
      term
    when *%w(1.1 1.2 1.3 2.2 3.1 3.3)
      term[0..-2]
    when *%w(1.4 1.6 2.1 2.3 3.2 3.4 3.5)
      term[0..-3]
    end
  end

  NOUN_VARIANTS.each do |variant|
    define_method("display_#{variant}") do
      return send(variant) if send(variant).present?
      return stem + ending(variant) if regular_noun? && ending(variant)
    end
  end

end