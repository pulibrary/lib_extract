### Retrieve item info for an arbitary array of item IDs
def get_item_info_for_item_ids(item_ids, conn)
  items = {}
  item_ids.each_slice(1000) do |segment|
    query = item_info_for_item_ids(segment)
    conn.exec(query, *segment) do |row|
      item_id = row.shift
      items[item_id] = {}
      items[item_id][:perm_type] = row.shift
      items[item_id][:temp_type] = row.shift
      items[item_id][:create_date] = row.shift
      items[item_id][:mod_date] = row.shift
      items[item_id][:perm_loc] = row.shift
      items[item_id][:temp_loc] = row.shift
      items[item_id][:on_reserve] = row.shift
      items[item_id][:barcode] = row.shift
      enum = row.shift
      enum = valid_ascii(enum)
      items[item_id][:enum] = enum
      chron = row.shift
      chron = valid_ascii(chron)
      items[item_id][:chron] = chron
      items[item_id][:copy_num] = row.shift
    end
  end
  items
end

### Retrieve items that have circulated in a given date range;
#     date format is mm-dd-yyyy
def get_items_circulated_dates(date1, date2, conn)
  items = []
  query = items_circulated_current_dates
  cursor = conn.parse(query)
  cursor.bind_param(:date1, date1)
  cursor.bind_param(:date2, date2)
  cursor.exec
  while row = cursor.fetch
    items << row.first
  end
  cursor.close
  query = items_circulated_archive_dates
  cursor = conn.parse(query)
  cursor.bind_param(:date1, date1)
  cursor.bind_param(:date2, date2)
  cursor.exec
  while row = cursor.fetch
    items << row.first
  end
  cursor.close
  items.uniq!
  items.sort
end

### Retrieve items by item types and date range;
#     date format is mm-dd-yyyy
def get_items_by_perm_type_create_date(item_types, date1, date2, conn)
  items = []
  query = items_by_perm_type_create_date
  cursor = conn.parse(query)
  cursor.bind_param(:date1, date1)
  cursor.bind_param(:date2, date2)
  item_types.each do |item_type|
    cursor.bind_param(:perm_type, item_type)
    cursor.exec
    while row = cursor.fetch
      items << row.first
    end
  end
  cursor.close
  items.uniq!
  items.sort
end

### Retrieve items for a given patron with a due date before the given date
def get_item_ids_for_patron_due_date(patron_id, due_date, conn)
  item_ids = []
  cursor = conn.parse(items_for_patron)
  cursor.bind_param(':patron_id', patron_id)
  cursor.bind_param(':due_date', due_date)
  cursor.exec
  while row = cursor.fetch
    item_ids << row.first
  end
  cursor.close
  item_ids
end

def get_items_for_mfhds(mfhd_ids, conn)
  results = {}
  mfhd_ids.each_slice(1000) do |slice|
    query = items_for_mfhds(slice)
    conn.exec(query, *slice) do |row|
      mfhd_id = row[0]
      results[mfhd_id] = [] unless results[mfhd_id]
      item_id = row[1]
      results[mfhd_id] << item_id
    end
  end
  results
end

def get_current_issues(mfhd_ids, conn)
  issue_hash = {}
  cursor = conn.parse(current_periodicals)
  mfhd_ids.each do |mfhd_id|
    issues = []
    cursor.bind_param(':mfhd_id', mfhd_id)
    cursor.exec
    while row = cursor.fetch
      issues << row.first
    end
    issue_hash[mfhd_id] = issues unless issues.empty?
  end
  cursor.close
  issue_hash
end

def get_items_for_patron(patron_id, due_date, conn)
  item_ids = get_item_ids_for_patron(patron_id, due_date, conn)
  get_bib_info_for_items(item_ids, conn)
end
