module TestHelper
  def random_comma_segment(word)
    word.split(/\s*,\s*/).sample
  end
  def word_classes
    Word::CLASSES.keys.map {|w| [w.to_s.titleize, w] }
  end
  def test_label(option, column)
    case column.to_sym
    when :properties, :property
      option.humanize
    when :variant, :variant_key
      simple_format(option.split('|').map(&:humanize).join("\n"))
    else
      option
    end
  end
end