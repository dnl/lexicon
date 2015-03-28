module Preposition

  PREPOSITION_RE = /^
                   (?<term>[\p{Greek}'’\/\s]+)
                   \s\+\s
                   (?<takes_case>
                    acc(?:\.|usative)?|
                    gen(?:\.|[ei]tive)?|
                    dat(?:\.|ive)?)
                   /ix
  PREPOSITION_CASES = [:accusative, :genitive, :dative]

  def preposition?
    return word_class == :preposition if word_class.present?
    !! lexical_form.match(PREPOSITION_RE)
  end

  def preposition_term
    lexical_form.match(PREPOSITION_RE).try(:[], :term) || lexical_form
  end


  def term_with_case_taken
    "#{term}#{preposition_lexical_tail}"
  end

  def display_takes_case
    return unless preposition?
    takes_case = takes_case if takes_case.present?
    takes_case ||= lexical_form.match(PREPOSITION_RE).try(:[], :takes_case)
    case takes_case
      when /^a/ then :accusative
      when /^g/ then :genitive
      when /^d/ then :dative
    end
  end



  def preposition_lexical_tail
    " + #{display_takes_case}" if display_takes_case.present?
  end
end