
def lccns_from_record(record)
  lccn = []
  f010 = record.fields('010')
  f010.each do |field|
    next unless field['a']
    value = StdNum::LCCN.normalize(field['a'])
    lccn << value if value
  end
  lccn.uniq
end

def isbns_from_record(record)
  isbn = []
  f020 = record.fields('020')
  f020.each do |field|
    next unless field['a']
    value = isbn_normalize(field['a'])
    isbn << value if value
  end
  isbn.uniq
end

def issns_from_record(record)
  issn = []
  f022 = record.fields('022')
  f022.each do |field|
    field.subfields.each do |subfield|
      next unless %w[a l].include?(subfield.code)
      value = issn_normalize(subfield.value)
      issn << value if value
    end
  end
  issn.uniq
end

def oclcs_from_record(record)
  oclc = []
  f035 = record.fields('035')
  f035.each do |field|
    next unless field['a']
    value = oclc_normalize(field['a'])
    oclc << value if value
  end
  oclc.uniq
end

### Get OCLC cross-reference numbers from a MARC record
def oclc_xref_from_record(record)
  xref = []
  record.fields('019').each do |field|
    field.subfields.each do |subfield|
      next unless subfield.code == 'a'
      value = oclc_normalize(subfield.value, false)
      xref << value if value
    end
  end
  xref.uniq
end

### Get all library standard numbers from a MARC record
def std_nos_from_record(record)
  lccn = lccns_from_record(record)
  isbn = isbns_from_record(record)
  issn = issns_from_record(record)
  oclc = oclcs_from_record(record)
  { lccn: lccn, isbn: isbn, issn: issn, oclc: oclc }
end

### Return 035s with a specific identifier prefix, e.g. SFX
def get_035_with_prefix_from_record(record, prefix)
  f035 = record.fields('035').select do |field|
    field['a'].to_s =~ /^\(#{prefix}\)/
  end
  return f035 if f035.empty?
  f035.map { |field| field['a'].gsub(/^\(#{prefix}\)(.*)$/, '\1') }
end

### Retrieve OCLC numbers from a given field
###   that are in subfields with the given subfield code
def get_oclc_from_field(field, subf_code)
  values = []
  return values unless field[subf_code]
  field.subfields.select { |subf| subf.code == subf_code }.each do |subfield|
    val = oclc_normalize(subfield.value)
    values << val if val
  end
  values.uniq
end

### Get standard numbers, bib ID, and brief title from a MARC record
def get_overlap_info_from_record(record)
  std_nos = std_nos_from_record(record)
  return nil if std_nos.nil?
  id = record['001'].value
  title = get_title_from_record(record)
  title_brief = brief_title_from_title_string(title)
  title880 = get_880_title_from_record(record)
  title880_brief = brief_880_title_from_title_string(title880)
  {
    id: id,
    std_nos: std_nos,
    title_brief: title_brief,
    title880_brief: title880_brief
  }
end

### Get format of record from leader
def get_format_from_leader(leader)
  leader[6..7]
end

### Country codes for all US, UK, and Canada states/provinces
def us_uk_canada_country_codes
  %w[
    enk
    aku
    alu
    cau
    xxu
    aru
    xxc
    cou
    ctu
    dcu
    deu
    flu
    gau
    hiu
    iau
    idu
    ilu
    inu
    ksu
    kyu
    mau
    mdu
    meu
    miu
    mnu
    mou
    msu
    mtu
    nbu
    ncu
    ndu
    nhu
    nju
    nmu
    nvu
    nyu
    ohu
    oku
    oru
    pau
    riu
    scu
    sdu
    tnu
    txu
    utu
    vau
    vtu
    wau
    wiu
    wvu
    wyu
    abc
    bcc
    mbc
    nfc
    nkc
    nsc
    ntc
    nuc
    onc
    quc
    snc
    xxk
    wlk
    stk
  ]
end

### Normalize dates found in 008, accounting for unknown dates,
###   convert to integers
def normalize_pub_dates(date1, date2)
  if ['    ', '||||'].include?(date1)
    date1 = 0
  else
    date1.gsub!(/[^0-9]/, '0')
    date1 = date1.to_i
  end
  if ['    ', '||||'].include?(date2)
    date2 = 0
  else
    date2.gsub!(/[^0-9]/, '9')
    date2 = date2.to_i
  end
  { date1: date1, date2: date2 }
end

### Take dates from 008 field and convert them to integers
def get_dates_from_008(f008)
  date_type = f008.value[6]
  date1 = f008.value[7..10]
  date2 = f008.value[11..14]
  norm_dates = normalize_pub_dates(date1, date2)
  { date_type: date_type, date1: norm_dates[:date1], date2: norm_dates[:date2] }
end

### Get publication place from 008 field
def get_pub_place_from_008(f008)
  f008.value[15..17].strip
end

### Get language code from 008 field
def get_lang_from_008(f008)
  f008.value[35..37]
end

def source_041_subfields
  %w[h m n]
end

### Get language codes from 041 fields; skip subfields relating to the
###   original language of the work
def get_original_lang_from_041(record)
  return nil unless record['041']
  languages = []
  record.fields('041').each do |field|
    field.subfields.each do |subfield|
      next if source_041_subfields.include?(subfield.code)
      vals = subfield.value.scan(/.{3}/)
      languages += vals
    end
  end
  languages
end

### Get all languages from 008 and 041 fields
def get_all_lang_from_record(record)
  f008_language = get_lang_from_008(record['008'])
  f041_languages = get_original_lang_from_041(record)
  languages = [f008_language]
  languages += f041_languages if f041_languages
  languages.uniq!
  languages.sort
end

def series_descriptive_subfield_codes
  %w[a b c d e f g h j k l m n o p q r s t u]
end

def series_statement_from_series_field(field)
  vol_subfield = 'v'
  issn_subfield = 'x'
  descriptive_subfields = field.subfields.select do |subfield|
    series_descriptive_subfield_codes.include?(subfield.code)
  end
  statement = descriptive_subfields.map(&:value).join(' ')
  volume = field[vol_subfield]
  issn = field[issn_subfield]
  { statement: statement, volume: volume, issn: issn }
end

### Collects all 400, 410, 411, 440 and 490/8xx series statements;
###   skips 490 with first indicator of '1' if there is an 8xx field
def get_series_from_record(record)
  all_series = []
  f8xx = record.fields('800'..'830')
  f490 = record.fields('490')
  f4xx = record.fields('400'..'440')
  return all_series if (f8xx + f490 + f4xx).empty?
  f8xx.each do |field|
    all_series << series_statement_from_series_field(field)
  end
  f4xx.each do |field|
    all_series << series_statement_from_series_field(field)
  end
  f490.each do |field|
    if f8xx.empty?
      all_series << series_statement_from_series_field(field)
    elsif field.indicator1 != '1'
      all_series << series_statement_from_series_field(field)
    end
  end
  all_series.uniq
end

### Get all 5xx fields from a record
def get_notes_from_record(record)
  notes = []
  record.fields('500'..'599').each do |field|
    text = ''
    field.subfields.each { |subf| text << subf.value + ' ' }
    text.strip!
    notes << { tag: field.tag, text: text }
  end
  notes
end

### Get all URLs in 856$u fields
def get_urls_from_record(record)
  urls = []
  f856 = record.fields('856')
  return urls if f856.empty?
  urls = f856.map { |field| field['u'].strip }
  urls.delete_if(&:nil?)
  urls
end

### Position 7 of leader is 'i' (integrating resource) or 's' (serial)
def journal?(leader)
  %w[i s].include?(leader[7])
end

def auth_subfields_to_skip(field_tag)
  case field_tag
  when '100', '110'
    %w[0 6 e]
  else
    %w[0 6 j]
  end
end

def get_author_from_record(record)
  auth_fields = record.fields(%w[100 110 111])
  return nil if auth_fields.empty?
  auth_field = auth_fields.first
  auth_tag = auth_field.tag
  subf_to_skip = auth_subfields_to_skip(auth_tag)
  targets = auth_field.subfields.reject do |subfield|
    subf_to_skip.include?(subfield.code)
  end
  author = targets.map(&:value).join(' ')
  scrub_string(author)
end

def get_880_title_from_record(record)
  f880 = record.fields('880')
  return nil if f880.empty?
  title_field = f880.select { |field| field['6'] && field['6'] =~ /^245/ }.first
  return nil unless title_field
  title_string = ''
  if title_field['a']
    title_string = title_field['a']
  else
    targets = title_field.subfields.reject { |subfield| subfield.code == '6' }
    c_index = targets.index { |subfield| subfield.code == 'c' }
    c_index ||= -1
    subf_values = targets[0..c_index].map(&:value)
    title_string = subf_values.join(' ')
  end
  scrub_string(title_string)
end

def get_title_from_record(record)
  f245 = record['245']
  return nil unless f245
  title_string = ''
  if f245['a']
    title_string = f245['a']
  else
    targets = f245.subfields.reject { |subfield| subfield.code == '6' }
    c_index = targets.index { |subfield| subfield.code == 'c' }
    c_index ||= -1
    subf_values = targets[0..c_index].map(&:value)
    title_string = subf_values.join(' ')
  end
  scrub_string(title_string)
end

def get_description_from_record(record)
  f300 = record['300']
  return nil unless f300
  subf_values = f300.subfields.map(&:value)
  text = subf_values.join(' ')
  scrub_string(text)
end

### Get edition, imprint, etc. data from 25x fields
def get_25x_fields_from_record(record)
  target_fields = record.fields('250'..'259')
  return target_fields if target_fields.empty?
  fields = []
  target_fields.each do |field|
    tag = field.tag
    text = field.subfields.join(' ')
    fields << { tag: tag, text: text }
  end
  fields
end

def get_publisher_info_from_record(record)
  f260 = record['260']
  f264 = record.fields('264')
  return publisher_info(f260) if f260
  unless f264.empty?
    target_field = select_264(f264)
    return publisher_info(target_field)
  end
  { pub_place: nil, pub_name: nil, pub_date: nil }
end

def scrub_string(string)
  return string if string.nil?
  string.strip!
  string[-1] = '' if string[-1] =~ /[.,:\/=]/
  string.strip
  string.gsub(/(\s){2, }/, '\1')
end

def publisher_info(field)
  pub_place = scrub_string(field['a'])
  pub_name = scrub_string(field['b'])
  pub_date = scrub_string(field['c'])
  { pub_place: pub_place, pub_name: pub_name, pub_date: pub_date }
end

def select_264(f264)
  f264.sort_by(&:indicator2).first
end

def get_subjects_from_record(record)
  subjects = []
  f6xx = record.fields('600'..'699')
  return subjects if f6xx.empty?
  f6xx.delete_if do |field|
    field.indicator2 != '0' ||
      (field.indicator2 == '7' && %w[lcgft aat].include?(field['2']))
  end
  return subjects if f6xx.empty?
  f6xx.each do |field|
    tag = field.tag
    text = ''
    field.subfields.each do |subfield|
      case subfield.code
      when 'v', 'x', 'y', 'z'
        text << ' -- ' + subfield.value
      when /[a-z]/
        text << ' ' + subfield.value
      end
    end
    text = scrub_string(text)
    subjects << { tag: tag, text: text }
  end
  subjects
end

def get_holdings_statements_from_866(f866)
  return nil if f866.empty?
  f866.delete_if { |field| field['a'].nil? }
  return nil if f866.empty?
  statements = {}
  f866.each do |field|
    mfhd_id = field['0'].to_i
    statement = field['a']
    statements[mfhd_id] = [] unless statements[mfhd_id]
    statements[mfhd_id] << statement
  end
  statements
end

def get_call_num_from_050(record)
  return nil unless record['050']
  targets = record['050'].subfields.select do |subfield|
    %w[a b].include?(subfield.code)
  end
  return nil if targets.empty?
  targets.map(&:value).join(' ')
end

### Combine data elements needed for LC slips for selectors
def get_lc_slip_data_from_record(record)
  id = record['001'].value.strip
  call_num = get_call_num_from_050(record)
  subjects = get_subjects_from_record(record)
  f008_language = get_lang_from_008(record['008'])
  f041_languages = get_original_lang_from_041(record)
  languages = [f008_language]
  languages += f041_languages if f041_languages
  languages.uniq!
  languages.sort!
  f008_pub_place = get_pub_place_from_008(record['008'])
  format = get_format_from_leader(record.leader)
  title = get_title_from_record(record)
  author = get_author_from_record(record)
  pub_info = get_publisher_info_from_record(record)
  description = get_description_from_record(record)
  f25x = get_25x_fields_from_record(record)
  std_nos = std_nos_from_record(record)
  f008_dates = get_dates_from_008(record['008'])
  { id: id, call_num: call_num, subjects: subjects, languages: languages, f008_pub_place: f008_pub_place, format: format, title: title, author: author, pub_info: pub_info, description: description, f25x: f25x, std_nos: std_nos, f008_dates: f008_dates }
end

def get_call_num_from_852(f852)
  targets = f852.subfields.select { |subf| %w[h i].include?(subf.code) }
  return nil if targets.empty?
  targets.map(&:value).join(' ')
end

def get_info_from_852(f852)
  mfhds = []
  f852.each do |field|
    mfhd_id = field['0'].to_i
    call_num = call_num_from_852(field)
    location = field['b']
    mfhds << { mfhd_id: mfhd_id, location: location, call_num: call_num }
  end
  mfhds
end

def get_holdings_info_from_record(record)
  f852 = record.fields('852')
  return nil if f852.empty?
  mfhds = info_from_852(f852)
  holdings_statements = holdings_statements_from_866(record.fields('866'))
  if holdings_statements
    mfhds.each do |mfhd|
      mfhd[:holdings_statements] = holdings_statements[mfhd[:mfhd_id]]
    end
  end
  mfhds
end
