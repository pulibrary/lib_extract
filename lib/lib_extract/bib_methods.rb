### Get all library standard numbers for an array of bib IDs
def get_standard_nos_for_bibs(bib_ids, conn)
  results = {}
  bib_ids.each_slice(1000) do |chunk|
    query = bib_std_nos(chunk)
    conn.exec(query, *chunk) do |row|
      bib_id = row.shift
      next unless bib_id
      code = row.shift
      index_code = index_code_to_stdno_type(code)
      display_val = row.shift
      value = case index_code
              when 'ISBN'
                isbn_normalize(display_val)
              when 'ISSN'
                issn_normalize(display_val)
              when 'OCLC'
                oclc_normalize(display_val)
              when 'LCCN'
                StdNum::LCCN.normalize(display_val)
              end
      next unless value
      results[bib_id] ||= {}
      results[bib_id][index_code] ||= []
      results[bib_id][index_code] << value
    end
  end
  results
end

### Get all unsuppressed bib IDs attached to holdings
def get_all_bib_ids(conn)
  ids = []
  query = all_bib_ids
  conn.exec(query) do |row|
    ids << row.first
  end
  ids.sort
end

### Get bib IDs for an array of 008 dates (string)
def get_bib_ids_008_date1(dates, conn)
  ids = []
  query = bib_ids_008_date1(dates)
  conn.exec(query, *dates) do |row|
    ids << row.first
  end
  ids.sort
end

### Get bib IDs for an array of 035 values
def get_bib_ids_035a(values, conn)
  ids = []
  values.each_slice(1000) do |segment|
    query = bib_ids_035a(segment)
    conn.exec(query, *segment) do |row|
      ids << row.first
    end
  end
  ids.sort
end

### Get bib IDs for an array of location codes
def get_bib_ids_for_locations(locations, conn)
  ids = []
  query = bib_ids_for_locations(locations)
  conn.exec(query, *locations) do |row|
    ids << row.first
  end
  ids
end

### Retrieve bib IDs by 008 language
#     and bib create date in form mm-dd-yyyy
def get_bib_ids_languages_dates(languages, date1, date2, conn)
  ids = []
  query = bib_ids_languages_dates(languages, date1, date2)
  conn.exec(query, *languages) do |row|
    ids << row.first
  end
  ids.sort
end

### Retrieve bib IDs by PO allocated fund
#     and current attached fiscal year
def get_bib_ids_orderfund_ledger(fund_code, ledger, conn)
  ids = []
  query = bib_ids_orderfund_ledger
  cursor = conn.parse(query)
  cursor.bind_param(':ledger', ledger)
  cursor.bind_param(':fund_code', fund_code)
  cursor.exec
  while row = cursor.fetch
    ids << row.first
  end
  cursor.close
  ids.sort
end

### Retrieve bib IDs by vendor code
def get_bib_ids_vendor(vendor_code, conn)
  ids = []
  query = bib_ids_vendor
  cursor = conn.parse(query)
  cursor.bind_param(':vendor_code', vendor_code)
  cursor.exec
  while row = cursor.fetch
    ids << row.first
  end
  cursor.close
  ids.sort
end

### Retrieve bib IDs by fiscal year paid
def get_bib_ids_ledger_paid(ledger, conn)
  ids = []
  query = bib_ids_ledger_paid
  cursor = conn.parse(query)
  cursor.bind_param(':ledger', ledger)
  cursor.exec
  while row = cursor.fetch
    ids << row.first
  end
  cursor.close
  ids.sort
end

def get_mfhd_ids_ledger_paid(ledger, conn)
  ids = []
  query = mfhd_ids_ledger_paid
  cursor = conn.parse(query)
  cursor.bind_param(':ledger', ledger)
  cursor.exec
  while row = cursor.fetch
    ids << row.first
  end
  cursor.close
  ids.sort
end

### Retrieve bib IDs by a basic call number pattern (i.e., ML or PS3556)
def get_bib_ids_callnum(callnum, conn)
  ids = []
  query = bib_ids_callnum
  cursor = conn.parse(query)
  cursor.bind_param(':pattern', callnum)
  cursor.exec
  while row = cursor.fetch
    ids << row.first
  end
  cursor.close
  ids.sort
end

### Retrieve bib IDs by location code and basic call number pattern
def get_bib_ids_location_callnum(location, callnum, conn)
  ids = []
  query = bib_ids_location_callnum
  cursor = conn.parse(query)
  cursor.bind_param(':location', location)
  cursor.bind_param(':pattern', callnum)
  cursor.exec
  while row = cursor.fetch
    ids << row.first
  end
  cursor.close
  ids.sort
end

### Returns a hash with item IDs as keys and bib IDs as values
def get_bib_ids_for_items(item_ids, conn)
  results = {}
  item_ids.each_slice(1000) do |segment|
    query = bib_ids_for_items(segment)
    conn.exec(query, *segment) do |row|
      bib_id = row.shift
      item_id = row.shift
      results[item_id] ||= []
      results[item_id] << bib_id
    end
  end
  results
end

### Get bib IDs for records with
###   specific formats in the leader, e.g., 'as' or 'cm'
def get_bib_ids_formats(formats, conn)
  ids = []
  query = bib_ids_formats(formats)
  conn.exec(query, *formats) do |row|
    ids << row.first
  end
  ids.sort
end

### Get bib info for an arbitrary array of bib IDs
def get_bib_info_for_bib_ids(bib_ids, conn)
  results = {}
  bib_ids.each_slice(1000) do |segment|
    query = bib_info_for_bib_ids(segment)
    conn.exec(query, *segment) do |row|
      hash = {}
      bib_id = row.shift
      title = row.shift
      if title
        title.force_encoding('UTF-8')
        title.scrub!('')
        title.strip!
      end
      hash[:title] = title
      author = row.shift
      if author
        author.force_encoding('UTF-8')
        author.scrub!('')
        author.strip!
      end
      hash[:author] = author
      pub_place = row.shift
      if pub_place
        pub_place.force_encoding('UTF-8')
        pub_place.scrub!('')
        pub_place.strip!
      end
      hash[:pub_place] = pub_place
      publisher = row.shift
      if publisher
        publisher.force_encoding('UTF-8')
        publisher.scrub!('')
        publisher.strip!
      end
      hash[:publisher] = publisher
      pub_date = row.shift
      if pub_date
        pub_date.force_encoding('UTF-8')
        pub_date.scrub!('')
        pub_date.strip!
      end
      hash[:pub_date] = pub_date
      hash[:date_type] = row.shift
      hash[:date1] = row.shift
      hash[:date2] = row.shift
      edition = row.shift
      if edition
        edition.force_encoding('UTF-8')
        edition.scrub!('')
        edition.strip!
      end
      hash[:edition] = edition
      hash[:place_code] = row.shift
      hash[:language] = row.shift
      hash[:bib_format] = row.shift
      hash[:bib_suppress] = row.shift
      results[bib_id] = hash
    end
  end
  results
end

###  Determine if the given call number falls under the desired
#      LC class and between the numbers given (decimals allowed)
def lc_call_num_filter?(call_no, low_num, high_num, lc_class)
  return false unless call_no
  string = call_no.gsub(/[\s]/, '')
  callnum_class = string.gsub(/^([A-Z]+).*$/, '\1')
  return false if lc_class != callnum_class
  num = string.gsub(/^[^0-9]+([0-9]+)(\.[0-9]+)?[^0-9]?.*$/, '\1\2')
  return false if num =~ /[^0-9]/
  num = num.to_f
  num.between?(low_num, high_num)
end

### Determine if the given call number falls under any of the desired
#     LC call number ranges given; call_num_ranges is an array of hashes with
#     the following keys: class (LC class letters), low_num(integer or float),
#     high_num(integer or float)
def multi_lc_call_num_filter?(call_num, call_num_ranges)
  call_num_ranges.each do |range|
    return true if lc_call_num_filter?(call_num,
                                       range[:low_num],
                                       range[:high_num],
                                       range[:class])
  end
  false
end

### Determine if the given call number falls under the desired
#     Richardson decimal class; Richardson numbers are decimal numbers;
#     low_num and high_num are decimals;
#     greater than or equal to low number and less than high number
def richardson_call_num_filter?(call_no, low_num, high_num)
  return false unless call_no
  return false unless call_no =~ /^[0-9\.]+$/
  num = call_no.delete('.')
  num = "0.#{num}".to_f
  num >= low_num && num < high_num
end

### Get MFHD info for MFHDs that match a basic call number pattern,
###   grouped by attached bib ID
def get_mfhd_info_callnum(callnum, conn)
  results = {}
  query = mfhd_info_callnum
  cursor = conn.parse(query)
  cursor.bind_param(':pattern', callnum)
  cursor.exec
  while row = cursor.fetch
    bib_id = row.shift
    results[bib_id] ||= []
    hash = {}
    hash[:mfhd_id] = row.shift
    hash[:mfhd_loc] = row.shift
    hash[:call_num] = row.shift
    hash[:normalized_call_num] = row.shift
    hash[:call_num_prefix] = row.shift
    results[bib_id] << hash
  end
  cursor.close
  results
end

### Get MFHD info for an array of bib IDs,
#     grouped by bib ID
def get_mfhd_info_for_bibs(bib_ids, conn)
  results = {}
  bib_ids.each_slice(1000) do |slice|
    query = mfhd_info_for_bibs(slice)
    conn.exec(query, *slice) do |row|
      bib_id = row.shift
      results[bib_id] ||= []
      hash = {}
      hash[:mfhd_id] = row.shift
      hash[:mfhd_loc] = row.shift
      call_num = row.shift
      call_num = format_call_num(call_num)
      hash[:call_num] = call_num
      hash[:normalized_call_num] = row.shift
      hash[:call_num_prefix] = row.shift
      hash[:mfhd_suppress] = row.shift
      results[bib_id] << hash
    end
  end
  results
end

def get_recap_locations(conn)
  locations = []
  query = recap_locations
  conn.exec(query) do |row|
    locations << row.first
  end
  locations
end

def get_phys_desc_for_bibs(bib_ids, conn)
  results = {}
  bib_ids.each_slice(1000) do |slice|
    query = physical_descriptions(slice)
    conn.exec(query, *slice) do |row|
      bib_id = row.shift
      phys_desc = row.shift
      results[bib_id] = phys_desc
    end
  end
  results
end
