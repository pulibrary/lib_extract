### Date format for all dates is mm-dd-yyyy

### Borrow Direct lending patron group codes
def bd_patron_groups
  %w[BDIR]
end

### ILL lending patron group codes
def ill_patron_groups
  %w[ILL]
end

### Patron group codes for internal library workflows
def internal_patron_groups
  %w[LMAN]
end

### SCSB lending patron group codes
def scsb_patron_groups
  %w[HTC]
end

### SCSB EDD patron group code for PUL requests
def local_edd_patron_groups
  %w[PULEDD]
end

### SCSB EDD patron group code for non-PUL requests
def scsb_edd_patron_groups
  %w[EDD]
end

### SCSB borrowing item type codes
def scsb_item_types
  %w[rcpshare]
end

### Borrow Direct borrowing item type codes
def bd_item_types
  %w[6-Week]
end

### Determine type of transaction by patron group and item type criteria
def transaction_type(patron_group, item_type)
  if internal_patron_groups.include?(patron_group)
    'internal'
  elsif scsb_item_types.include?(item_type)
    'scsb_borrow'
  elsif scsb_patron_groups.include?(patron_group)
    'scsb_lend'
  elsif local_edd_patron_groups.include?(patron_group)
    'local_edd'
  elsif scsb_edd_patron_groups.include?(patron_group)
    'scsb_edd'
  elsif bd_item_types.include?(item_type)
    'bd_borrow'
  elsif bd_patron_groups.include?(patron_group)
    'bd_lend'
  elsif ill_patron_groups.include?(patron_group)
    'ill_lend'
  else
    'local'
  end
end

### Retrieve current circ transactions in a date range for a happening location
def get_current_circ_by_circ_location(circ_location, date1, date2, conn)
  current_circ = []
  cursor = conn.parse(current_circ_by_circloc_dates)
  cursor.bind_param(':location_code', circ_location)
  cursor.bind_param(':date1', date1)
  cursor.bind_param(':date2', date2)
  cursor.exec
  while row = cursor.fetch
    hash = {}
    hash[:trans_id] = row[0]
    hash[:item_id] = row[1]
    hash[:patron_group] = row[2]
    hash[:charge_date] = row[3]
    hash[:renewal_count] = row[4]
    hash[:item_type] = row[5]
    hash[:circ_type] = transaction_type(hash[:patron_group], hash[:item_type])
    current_circ << hash
  end
  cursor.close
  cursor = conn.parse(current_circ_by_circloc_dates_null_item)
  cursor.bind_param(':location_code', circ_location)
  cursor.bind_param(':date1', date1)
  cursor.bind_param(':date2', date2)
  cursor.exec
  while row = cursor.fetch
    hash = {}
    hash[:trans_id] = row[0]
    hash[:item_id] = row[1]
    hash[:patron_group] = row[2]
    hash[:charge_date] = row[3]
    hash[:renewal_count] = row[4]
    hash[:item_type] = row[5]
    hash[:circ_type] = transaction_type(hash[:patron_group], hash[:item_type])
    current_circ << hash
  end
  cursor.close
  current_circ
end

### Retrieve archived circ transactions in a date range for a happening location
def get_archive_circ_by_circ_location(circ_location, date1, date2, conn)
  archive_circ = []
  cursor = conn.parse(archive_circ_by_circloc_dates)
  cursor.bind_param(':location_code', circ_location)
  cursor.bind_param(':date1', date1)
  cursor.bind_param(':date2', date2)
  cursor.exec
  while row = cursor.fetch
    hash = {}
    hash[:trans_id] = row[0]
    hash[:item_id] = row[1]
    hash[:patron_group] = row[2]
    hash[:charge_date] = row[3]
    hash[:renewal_count] = row[4]
    hash[:item_type] = row[5]
    hash[:circ_type] = transaction_type(hash[:patron_group], hash[:item_type])
    archive_circ << hash
  end
  cursor.close
  cursor = conn.parse(archive_circ_by_circloc_dates_null_item)
  cursor.bind_param(':location_code', circ_location)
  cursor.bind_param(':date1', date1)
  cursor.bind_param(':date2', date2)
  cursor.exec
  while row = cursor.fetch
    hash = {}
    hash[:trans_id] = row[0]
    hash[:item_id] = row[1]
    hash[:patron_group] = row[2]
    hash[:charge_date] = row[3]
    hash[:renewal_count] = row[4]
    hash[:item_type] = row[5]
    hash[:circ_type] = transaction_type(hash[:patron_group], hash[:item_type])
    archive_circ << hash
  end
  cursor.close
  archive_circ
end

### Retrieve all circ transactions in a date range for a happening location
def get_all_circ_by_circ_location(circ_location, date1, date2, conn)
  results = {}
  current_circ = get_current_circ_by_circ_location(circ_location, date1, date2, conn)
  archive_circ = get_archive_circ_by_circ_location(circ_location, date1, date2, conn)
  results[:current_circ] = current_circ
  results[:archive_circ] = archive_circ
  results
end

### Retrieve all circ happening locations
def get_circ_locations(conn)
  locations = []
  conn.exec(circ_locations_archive) do |row|
    hash = {}
    hash[:location_id] = row[0]
    hash[:location_code] = row[1]
    hash[:location_name] = row[2]
    locations << hash
  end
  conn.exec(circ_locations_current) do |row|
    hash = {}
    hash[:location_id] = row[0]
    hash[:location_code] = row[1]
    hash[:location_name] = row[2]
    locations << hash
  end
  locations.uniq
end

### Retrieve all circulation transactions for bibs one bib at a time;
#     ineffiecient for large groups of bib IDs
def get_circ_by_bibs(bib_ids, conn)
  lines = {}
  cursor = conn.parse(current_circ_by_bib)
  bib_ids.each do |bib_id|
    cursor.bind_param(':bib_id', bib_id)
    cursor.exec
    results = []
    while row = cursor.fetch
      hash = {}
      hash[:circ_trans_id] = row[0]
      hash[:item_id] = row[1]
      hash[:patron_group] = row[2]
      hash[:charge_date] = row[3]
      hash[:renewal_count] = row[4]
      hash[:item_type] = row[5]
      hash[:circ_type] = transaction_type(hash[:patron_group], hash[:item_type])
      results << hash
    end
    lines[bib_id] = {}
    lines[bib_id][:current_circ] = results
  end
  cursor.close
  cursor = conn.parse(archive_circ_by_bib)
  bib_ids.each do |bib_id|
    cursor.bind_param(':bib_id', bib_id)
    cursor.exec
    results = []
    while row = cursor.fetch
      hash = {}
      hash[:circ_trans_id] = row[0]
      hash[:item_id] = row[1]
      hash[:patron_group] = row[2]
      hash[:charge_date] = row[3]
      hash[:renewal_count] = row[4]
      hash[:item_type] = row[5]
      hash[:circ_type] = transaction_type(hash[:patron_group], hash[:item_type])
      results << hash
    end
    lines[bib_id][:archive_circ] = results
  end
  cursor.close
  lines
end

### Retrieve all circulation transactions in a date range for an array of MFHDs
def get_all_circ_for_mfhds(mfhd_ids, date1, date2, conn)
  results = {}
  mfhd_ids.each_slice(1000) do |slice|
    current = get_current_circ_for_mfhds(slice, date1, date2, conn)
    grouped_current = current.group_by { |line| line[:mfhd_id] }
    grouped_current.each do |mfhd_id, values|
      values.each do |hash|
        hash.delete(:mfhd_id)
      end
      results[mfhd_id] = []
      results[mfhd_id] += values
    end
    archive = get_archive_circ_for_mfhds(slice, date1, date2, conn)
    grouped_archive = archive.group_by { |line| line[:mfhd_id] }
    grouped_archive.each do |mfhd_id, values|
      values.each do |hash|
        hash.delete(:mfhd_id)
      end
      results[mfhd_id] = [] unless results[mfhd_id]
      results[mfhd_id] += values
    end
  end
  results
end

### Retrieve current circulation transactions for a group of MFHDs
# Limited to 1,000 MFHD IDs or less by the bind variable limitation
def get_current_circ_for_mfhds(mfhd_ids, date1, date2, conn)
  results = []
  query = current_circ_by_mfhds(mfhd_ids, date1, date2)
  conn.exec(query, *mfhd_ids) do |row|
    hash = {}
    hash[:mfhd_id] = row.shift
    hash[:circ_trans_id] = row.shift
    hash[:item_id] = row.shift
    hash[:patron_group] = row.shift
    hash[:charge_date] = row.shift
    hash[:renewal_count] = row.shift
    hash[:item_type] = row.shift
    hash[:circ_type] = transaction_type(hash[:patron_group], hash[:item_type])
    results << hash
  end
  results
end

### Retrieve archived circulation transactions for a group of MFHDs
# Limited to 1,000 MFHD IDs or less
def get_archive_circ_for_mfhds(mfhd_ids, date1, date2, conn)
  results = []
  query = archive_circ_by_mfhds(mfhd_ids, date1, date2)
  conn.exec(query, *mfhd_ids) do |row|
    hash = {}
    hash[:mfhd_id] = row.shift
    hash[:circ_trans_id] = row.shift
    hash[:item_id] = row.shift
    hash[:patron_group] = row.shift
    hash[:charge_date] = row.shift
    hash[:renewal_count] = row.shift
    hash[:item_type] = row.shift
    hash[:circ_type] = transaction_type(hash[:patron_group], hash[:item_type])
    results << hash
  end
  results
end

### Retrieve all circulation transactions in a date range for an array of Items
def get_all_circ_for_items(item_ids, date1, date2, conn)
  results = {}
  item_ids.each_slice(1000) do |slice|
    current = get_current_circ_for_items(slice, date1, date2, conn)
    current.each do |id, info|
      results[id] = info
    end
    archive = get_archive_circ_for_items(slice, date1, date2, conn)
    archive.each do |id, info|
      results[id] = [] unless results[id]
      results[id].concat(info)
    end
  end
  results
end

### Retrieve current circulation transactions for a group of Items
# Limited to 1,000 Item IDs or less by the bind variable limitation
def get_current_circ_for_items(item_ids, date1, date2, conn)
  results = {}
  query = current_circ_for_items(item_ids, date1, date2)
  conn.exec(query, *item_ids) do |row|
    hash = {}
    item_id = row[0]
    results[item_id] = [] unless results[item_id]
    hash[:circ_trans_id] = row[1]
    hash[:patron_group] = row[2]
    hash[:charge_date] = row[3]
    hash[:discharge_date] = row[4]
    hash[:renewal_count] = row[5]
    item_type = row[6]
    hash[:circ_type] = transaction_type(hash[:patron_group], item_type)
    results[item_id] << hash
  end
  results
end

### Retrieve archived circulation transactions for a group of Items
# Limited to 1,000 Item IDs or less
def get_archive_circ_for_items(item_ids, date1, date2, conn)
  results = {}
  query = archive_circ_for_items(item_ids, date1, date2)
  conn.exec(query, *item_ids) do |row|
    hash = {}
    item_id = row[0]
    results[item_id] = [] unless results[item_id]
    hash[:circ_trans_id] = row[1]
    hash[:patron_group] = row[2]
    hash[:charge_date] = row[3]
    hash[:discharge_date] = row[4]
    hash[:renewal_count] = row[5]
    item_type = row[6]
    hash[:circ_type] = transaction_type(hash[:patron_group], item_type)
    results[item_id] << hash
  end
  results
end

### Retrieve all holds and recalls in a date range for an array of items
def get_all_hold_recall_for_items(item_ids, date1, date2, conn)
  final_grouped = {}
  item_ids.each_slice(1000) do |slice|
    current = get_current_hold_recall_for_items(slice, date1, date2, conn)
    current.each do |k, v|
      final_grouped[k] = {}
      final_grouped[k][:current_holds] = v
    end
    archive = get_archive_hold_recall_for_items(slice, date1, date2, conn)
    archive.each do |k, v|
      final_grouped[k] = {} unless final_grouped[k]
      final_grouped[k][:archive_holds] = v
    end
  end
  final_grouped
end

### Retrieve current holds and recalls for a group of items
# Limited to 1,000 item IDs or less by the bind variable limitation
def get_current_hold_recall_for_items(item_ids, date1, date2, conn)
  results = {}
  query = current_holds_by_items(item_ids, date1, date2)
  conn.exec(query, *item_ids) do |row|
    hash = {}
    item_id = row[0]
    results[item_id] = [] unless results[item_id]
    hash[:hold_id] = row[1]
    hash[:hold_type] = row[2]
    hash[:pickup_loc] = row[3]
    hash[:expire_date] = row[4]
    hash[:create_date] = row[5]
    hash[:patron_group] = row[6]
    results[item_id] << hash
  end
  results
end

### Retrieve archived holds and recalls for a group of items
# Limited to 1,000 item IDs or less
def get_archive_hold_recall_for_items(item_ids, date1, date2, conn)
  results = {}
  query = archive_holds_by_items(item_ids, date1, date2)
  conn.exec(query, *item_ids) do |row|
    hash = {}
    item_id = row[0]
    results[item_id] = [] unless results[item_id]
    hash[:hold_id] = row[1]
    hash[:hold_type] = row[2]
    hash[:pickup_loc] = row[3]
    hash[:expire_date] = row[4]
    hash[:create_date] = row[5]
    hash[:patron_group] = row[6]
    results[item_id] << hash
  end
  results
end

### Retrieve all circ transactions for bib objects
# Expects MFHD ID to be in a hash with :mfhd_id as a key
def get_circ_for_lines(lines, date1, date2, conn)
  lines.each_slice(1000) do |segment|
    mfhd_ids = segment.map { |x| x[:mfhd_id] }.uniq.sort
    all_circ = get_all_circ_for_mfhds(mfhd_ids, date1, date2, conn)
    all_circ.each do |k, v|
      targets = lines.select { |x| x[:mfhd_id] == k }
      targets.each do |line|
        line[:current_circ] = v[:current_circ]
        line[:archive_circ] = v[:archive_circ]
      end
    end
  end
  lines
end

### Retrieve last circulation from a collection of circ transactions for a bib
def last_circ(line)
  last_circ = nil
  if line[:current_circ]
    last_circ = line[:current_circ].max_by { |x| x[:charge_date] }
  elsif line[:archive_circ]
    last_circ = line[:archive_circ].max_by { |x| x[:charge_date] }
  end
  last_circ
end

### Retrieve all item statuses for all items attached to a MFHD
def get_item_statuses_for_mfhd(mfhd_id, conn)
  statuses = []
  cursor = conn.parse(item_statuses_for_mfhd)
  cursor.bind_param(':mfhd_id', mfhd_id)
  cursor.exec
  while row = cursor.fetch
    statuses << row.first
  end
  statuses
end
