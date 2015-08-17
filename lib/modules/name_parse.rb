module NameParse

  def self.transliterate str, hFlg=true, andFlg=false
    # Based on permalink_fu by Rick Olsen

    # Escape str by transliterating to UTF-8 with Iconv
    s = str.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "")

    # Downcase string
    s.downcase! if hFlg

    # Remove apostrophes so isn't changes to isnt
    s.gsub!(/'/, '')

    # Remove ampersand so & changes to and
    s.gsub!(/&/, 'and') if andFlg

    # Replace any non-letter or non-number character with a space
    s.gsub!(/[^A-Za-z0-9]+/, ' ')

    # Remove spaces from beginning and end of string
    s.strip!

    # Replace groups of spaces with single hyphen
    s.gsub!(/\ +/, '-') if hFlg

    return s
  end

  # use array to substitute invalid url characters
  def self.parse_url str
    r = [[' ','_'], ['.','_']]
    r.each {|rep| str.gsub!(rep[0], rep[1])}
    str
  end

  # parse non-ascii chars
  def self.encode_string str
    encoding_options = {:invalid => :replace, :undef => :replace, :replace => '', :UNIVERSAL_NEWLINE_DECORATOR => true}
    str.encode!(Encoding.find('ASCII'), encoding_options)
    str
  end
end
