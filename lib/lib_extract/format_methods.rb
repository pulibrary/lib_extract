### Create brief title for overlap analysis
def brief_title_from_title_string(title)
  return nil unless title
  normalized = title.downcase.unicode_normalize(:nfd)
  normalized.gsub!(/[^A-Za-z ]/, '')
  title_words = normalized.split
  title_words[0..3].join(' ')
end

def brief_880_title_from_title_string(title)
  return nil unless title
  normalized = title.downcase.unicode_normalize(:nfd)
  title_words = normalized.split
  title_words[0..3].join(' ')
end

### Remove all characters from a pub date field except the year
def process_pub_date(date)
  return date if date.nil?
  date.gsub(/^[^0-9]*([0-9]+)[^0-9]?.*$/, '\1')
end

### Translate Voyager BIB_INDEX codes to standard num types
def index_code_to_stdno_type(code)
  return code if code.nil?
  case code
  when '010A'
    'LCCN'
  when '020A'
    'ISBN'
  when '022A' || '022L'
    'ISSN'
  when '0350'
    'OCLC'
  end
end

### Conversion to Unicode for enum/chron info
def valid_ascii(string)
  string.force_encoding('ascii').encode('UTF-8', invalid: :replace, replace: '') unless string.nil?
end

### Conversion to Unicode for name info
def valid_codepoints(string)
  string.codepoints.map { |c| c.chr(Encoding::UTF_8) }.join unless string.nil?
end

### Voyager stores call numbers as ASCII,
###   even though it accepts Unicode characters in the field;
###   diacritics are not normally part of a call number
def format_call_num(call_num)
  return call_num if call_num.nil?
  call_num.force_encoding('UTF-8')
  call_num.scrub!('')
  call_num.unicode_normalize!(:nfd)
  call_num.gsub!(/[\u0300-\u036f]/, '')
  call_num
end

def merge_enum_chron(enum, chron)
  if enum.nil?
    chron
  else
    string = enum
    string << " (#{chron})" if chron
    string.force_encoding('UTF-8')
    string.scrub!('')
    string.strip
  end
end

### Normalize OCLC numbers
def oclc_normalize(oclc, prefix = true)
  if prefix == true
    return nil unless oclc.downcase =~ /^\(ocolc\)/ || oclc =~ /^ocn[0-9]|^ocm[0-9]|^on[0-9]/
  end
  ### Do not process if there is a different prefix
  return nil if oclc.downcase =~ /\((?!ocolc)/
  oclc_num = oclc.gsub(/\D/, '').to_i.to_s
  return nil if oclc_num == '0'
  case oclc_num.length
  when 1..8
    '(OCoLC)' + 'ocm' + format('%08d', oclc_num)
  when 9
    '(OCoLC)' + 'ocn' + oclc_num
  else
    '(OCoLC)' + 'on' + oclc_num
  end
end

### Convert ISBN-10 to ISBN-13
def isbn10_to_13(isbn)
  stem = isbn[0..8]
  return nil if stem =~ /\D/
  existing_check = isbn[9]
  return nil if existing_check && existing_check != checkdigit_10(stem)
  main = ISBN13PREFIX + stem
  checkdigit = checkdigit_13(main)
  main + checkdigit
end

### Calculate check digit for ISBN-10
def checkdigit_10(stem)
  int_index = 0
  int_sum = 0
  stem.each_char do |digit|
    int_sum += digit.to_i * (10 - int_index)
    int_index += 1
  end
  mod = (11 - (int_sum % 11)) % 11
  mod == 10 ? 'X' : mod.to_s
end

### Calculate check digit for ISBN-13
def checkdigit_13(stem)
  int_index = 0
  int_sum = 0
  stem.each_char do |digit|
    int_sum += int_index.even? ? digit.to_i : digit.to_i * 3
    int_index += 1
  end
  ((10 - (int_sum % 10)) % 10).to_s
end

### Normalize ISBN-13
def isbn13_normalize(raw_isbn)
  int_sum = 0
  stem = raw_isbn[0..11]
  return nil if stem =~ /\D/
  int_index = 0
  stem.each_char do |digit|
    int_sum += int_index.even? ? digit.to_i : digit.to_i * 3
    int_index += 1
  end
  checkdigit = checkdigit_13(stem)
  return nil if raw_isbn[12] && raw_isbn[12] != checkdigit
  stem + checkdigit
end

### Normalize any given string that is supposed to include an ISBN
def isbn_normalize(isbn)
  return nil unless isbn
  raw_isbn = isbn.delete('-')
  raw_isbn = raw_isbn.delete('\\')
  raw_isbn.gsub!(/\([^\)]*\)/, '')
  raw_isbn.gsub!(/^(.*)\$c.*$/, '\1')
  raw_isbn.gsub!(/^(.*)\$q.*$/, '\1')
  raw_isbn.gsub!(/^\D+([0-9].*)$/, '\1')
  raw_isbn = raw_isbn.gsub(/^(978[0-9 ]+).*$/, '\1').delete(' ') if raw_isbn =~ /^978/
  raw_isbn.gsub!(/([0-9])\s*([0-9]{4})\s*([0-9]{4})\s*([0-9xX]).*$/, '\1\2\3\4') unless raw_isbn =~ /^978/
  raw_isbn.gsub!(/^([0-9]{9,13}[xX]?)[^0-9xX].*$/, '\1')
  raw_isbn.gsub!(/^([0-9]+?)\D.*$/, '\1')
  if raw_isbn.length > 6 && raw_isbn.length < 9 && raw_isbn =~ /^[0-9]+$/
    raw_isbn = raw_isbn.ljust(9, '0')
  end
  valid_lengths = [9, 10, 12, 13] # ISBN10 and ISBN13 with/out check digits
  return nil unless valid_lengths.include? raw_isbn.length
  if raw_isbn.length < 12
    isbn10_to_13(raw_isbn)
  else
    isbn13_normalize(raw_isbn)
  end
end

### Normalize any given string that is supposed to include an ISSN
def issn_normalize(issn)
  issn_num = issn.delete('-')
  issn_num = issn_num.gsub(/^\D+([0-9].*)$/, '\1')
  issn_num = issn_num.gsub(/^([0-9]{4})\s+([0-9xX]{4}).*$/, '\1\2')
  issn_num = issn_num.gsub(/^([0-9]{7,}[^\s]+)\s.*$/, '\1')
  valid_lengths = [7, 8]
  return nil unless valid_lengths.include? issn_num.length
  stem = issn_num[0..6]
  return nil if stem =~ /\D/
  int_sum = 0
  int_index = 0
  stem.each_char do |digit|
    int_sum += digit.to_i * (8 - int_index)
    int_index += 1
  end
  mod = (11 - (int_sum % 11)) % 11
  check_digit = mod == 10 ? 'X' : mod.to_s
  return nil if issn_num[7] && issn_num[7] != check_digit
  stem[0..3] + '-' + stem[4..6] + check_digit
end

### Create a pipe-delimited blob of text from unique values of an array
def array_to_blob(array)
  return nil if array.nil?
  array.uniq.join(' | ')
end

### fh is a file handle,
#     or any class that behaves like the File class (e.g., StringIO);
#     data is a hash derived from the get_lc_slip_data_from_record method
def write_lc_slip_data_to_fh(fh, data)
  fh.write("#{data[:id]}\t")
  fh.write("#{data[:std_nos][:isbn].join(' | ')}\t")
  fh.write("#{data[:std_nos][:lccn].join(' | ')}\t")
  fh.write("#{data[:author]}\t")
  fh.write("#{data[:title]}\t")
  fh.write("#{data[:f008_pub_place]}\t")
  fh.write("#{data[:pub_info][:pub_place]}\t")
  fh.write("#{data[:pub_info][:pub_name]}\t")
  fh.write("#{data[:pub_info][:pub_date]}\t")
  fh.write("#{data[:description]}\t")
  fh.write("#{data[:format]}\t")
  fh.write("#{data[:languages].join(' | ')}\t")
  fh.write("#{data[:call_num]}\t")
  subj_string = data[:subjects].map { |subject| subject[:text] }.join(' | ')
  fh.puts(subj_string)
end
