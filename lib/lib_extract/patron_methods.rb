def get_patron_info(patron_ids, conn)
  patrons = []
  patron_ids.each_slice(1000) do |segment|
    query = patron_info(segment)
    conn.exec(query, *segment) do |row|
      hash = {}
      hash[:patron_id] = row[0]
      hash[:title] = row[1]
      hash[:institution_id] = row[2]
      last_name = row[3]
      last_name = valid_codepoints(last_name) if last_name
      hash[:last_name] = last_name
      first_name = row[4]
      first_name = valid_codepoints(first_name) if first_name
      hash[:first_name] = first_name
      middle_name = row[5]
      middle_name = valid_codepoints(middle_name) if middle_name
      hash[:middle_name] = middle_name
      hash[:expire_date] = row[6]
      hash[:purge_date] = row[7]
      hash[:major] = row[8]
      hash[:department] = row[9]
      patrons << hash
    end
  end
  patrons
end

def get_active_patron_barcodes(patron_ids, conn)
  barcodes = {}
  patron_ids.each_slice(1000) do |segment|
    query = active_patron_barcodes(segment)
    conn.exec(query, *segment) do |row|
      id = row[0]
      barcode = row[1]
      patron_group = row[2]
      barcodes[id] = [] unless barcodes[:id]
      barcodes[id] << { barcode: barcode, patron_group: patron_group }
    end
  end
  barcodes
end

### Return most recent active email address
def get_patron_email_addresses(patron_ids, compare_date, conn)
  addresses = {}
  patron_ids.each_slice(1000) do |segment|
    grouped = {}
    query = patron_email_addresses(segment)
    conn.exec(query, *segment) do |row|
      id = row[0]
      email = row[1]
      expire_date = row[2]
      effect_date = row[3]
      next unless expire_date >= compare_date
      next unless effect_date <= compare_date
      grouped[id] = [] unless grouped[id]
      grouped[id] << { email: email, expire_date: expire_date, effect_date: effect_date }
    end
    next if grouped.empty?
    grouped.each do |id, vals|
      vals.sort! { |x, y| y[:expire_date] <=> x[:expire_date] }
      email = vals.first[:email]
      addresses[id] = email
    end
  end
  addresses
end

def get_current_patrons_with_charged_items(purge_date, due_date, conn)
  patron_ids = []
  cursor = conn.parse(current_patrons_with_charged_items)
  cursor.bind_param(':purge_date', purge_date)
  cursor.bind_param(':due_date', due_date)
  cursor.exec
  while row = cursor.fetch
    patron_ids << row.first
  end
  cursor.close
  patron_ids.sort
end

def get_all_patron_info(patron_ids, patron_date, conn)
  patrons = get_patron_info(patron_ids, conn)
  emails = get_patron_email_addresses(patron_ids, patron_date, conn)
  barcodes = get_active_patron_barcodes(patron_ids, conn)
  patrons.each do |patron|
    patron[:email] = emails[patron[:patron_id]]
    patron[:barcodes] = barcodes[patron[:patron_id]]
  end
  patrons
end
