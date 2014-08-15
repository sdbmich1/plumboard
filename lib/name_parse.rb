module NameParse

  def self.transliterate(str)
    # Based on permalink_fu by Rick Olsen

    # Escape str by transliterating to UTF-8 with Iconv
    s = str.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "")

    # Downcase string
    s.downcase!

    # Remove apostrophes so isn't changes to isnt
    s.gsub!(/'/, '')

    # Replace any non-letter or non-number character with a space
    s.gsub!(/[^A-Za-z0-9]+/, ' ')

    # Remove spaces from beginning and end of string
    s.strip!

    # Replace groups of spaces with single hyphen
    s.gsub!(/\ +/, '-')

    return s
  end

  # parse url string for correctness
  def self.parse_url str

    # use array to substitute invalid url characters
    r = [[' ','_'], ['.','_']]
    r.each {|rep| str.gsub!(rep[0], rep[1])}

    # return parsed url
    str
  end
end
