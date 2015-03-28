module Verb

  def verb?
    return word_class == :verb unless word_class.blank?
    return false if nounish?
    return false if preposition?
    return false if adjective?
    return true if term[-1] == 'ω'
  end

  def verbish?
    verb?
  end

  def verb_term
    lexical_form
  end

  PERSONS = [:first, :second, :third]
  TENSES = [:present, :future]

  VERB_VARIANTS = Word::NUMBERS.product(PERSONS)
                               .map {|n| n.map(&:to_s).join('_').to_sym }


  VERB_ENDINGS = {
    :regular => ['ω', 'εις', 'ει',  'ομεν',  'ετε', 'ουσιν'],
    :middle =>  ['ομαι', 'ῃ', 'ηται', 'ωμεθα', 'ησθε', 'ωνται'],
    :'αω'    => ['ω',  'ᾳς',  'ᾳ',  'ωμεν',  'ατε',  'ωσιν'],
    :'εω'    => ['ω', 'εις', 'ει', 'ουμεν', 'ειτε', 'ουσιν'],
    :'οω'    => ['ω', 'οις', 'οι', 'ουμεν', 'ουτε', 'ουσιν']
  }

  def verb_ending(variant, tense=:present)
    key = tense == :present ? ending_set : future_ending_set
    VERB_ENDINGS[key].try(:[], VERB_VARIANTS.index(variant))
  end


  def ending_set
    case term
      when /αω$/ then :'αω'
      when /εω$/ then :'εω'
      when /οω$/ then :'οω'
      when /ομαι$/ then :middle
      when /ω$/ then :regular
    end
  end

  def future_ending_set
    case term
      when /[λμνρ]ω$/ then :'εω'
      when /ω$/ then :regular
    end
  end

  def regular_verb?(tense=:present)
    #here I'm meaning regular to be 'consistent to some rule based on the endings in the dictionrary'

    ending_set.present? && (tense==:present || future_stem.present?)
  end

  def future_stem
    case term
      when /αω$/ then stem + 'ασ'
      when /εω$/ then stem + 'εσ'
      when /οω$/ then stem + 'οσ'
      when /[λμνρ]ω$/ then stem
      when /[πβφ]ω$/ then stem[0..-1] + 'ψ'
      when /[κγχ]ω$/ then stem[0..-1] + 'ξ'
      when /ζω$/ then stem[0..-1] + 'σ'
      when /σσω$/ then stem[0..-2] + 'ξ'
      when /πτω$/ then stem[0..-2] + 'ψ'
      when /ω$/  then stem + 'σ'
    end
  end

  def verb_stem(tense=:present)
    return future_stem if tense == :future
    case ending_set
      when :middle  then term[0..-4]
      when :regular then term[0..-2]
      else
        term[0..-3]
    end
  end

  VERB_VARIANTS.each do |variant|
    TENSES.each do |tense|
      define_method(:"display_#{tense}_#{variant}") do
        return send(:"#{tense}_#{variant}") if send(variant).present?
        return verb_stem(tense) + verb_ending(variant, tense) if regular_verb?(tense) && verb_ending(variant, tense)
      end
    end
    # present is default.
    alias_method :"display_#{variant}", :"display_present_#{variant}"
    #can't alias_method as these are built after talking to the db.
    define_method(:"present_#{variant}=") do |value|
      send(:"#{variant}=", value)
    end
    define_method(:"present_#{variant}") do
      send(:"#{variant}")
    end
  end


end