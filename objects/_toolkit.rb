# Add a few enhancements to the base String class
class String

  PLURAL_EXCEPTIONS ||= [].freeze

  # Given string x, find out if it is a x, an x, or are x
  def article
    if plural?
      ''
    elsif /^[aeiouAEIOU]/ =~ self
      'an'
    else
      'a'
    end
  end

  def with_article
    if !article.empty?
      "#{article} #{self}"
    else
      self
    end
  end

  # Detect if a string is plural
  def plural?
    return true if /s$/ =~ self && PLURAL_EXCEPTIONS.include?(self) == false

    false

  end

  # Special property for describing strings if they are the child of an entity
  def preposition=(val)
    @preposition = val.to_s
  end

  attr_reader :preposition

end

# Add and enhancement to the Hash class
class Hash

  def symbolize_keys
    Hash.transform_keys(&:to_sym)
  end

end

##
# Takes an array and picks a semi-random element, with the first
# elements weighted more frequently the the last elements by using
# the power of a given exponent.
def choose(list, exponent = 2)
  list_index = ((rand**exponent) * list.length).floor
  return '' if list[list_index] == 'NULL'

  list[list_index]

end
