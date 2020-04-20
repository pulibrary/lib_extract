def get_bib_coll(bib_ids, conn)
  segments = get_bib_coll_segments(bib_ids, conn)
  return nil if segments.empty?
  raw_marc = segments.join('')
  MARC::Reader.new(StringIO.new(raw_marc, 'r'), external_encoding: 'UTF-8', invalid: :replace, replace: '')
end

def get_bib_coll_segments(bib_ids, conn)
  query = bulk_bib(bib_ids)
  segments = []
  conn.exec(query, *bib_ids) do |row|
    segments << row.first
  end
  segments
end

def get_mfhds_for_bib_coll(bib_ids, conn)
  query = mfhds_for_bibs(bib_ids)
  mfhds_with_keys = {}
  conn.exec(query, *bib_ids) do |row|
    bib_id = row[0]
    mfhd_data = row[1]
    mfhds_with_keys[bib_id] = [] unless mfhds_with_keys[bib_id]
    mfhds_with_keys[bib_id] << mfhd_data
  end
  mfhd_collection = {}
  mfhds_with_keys.each do |bib_id, mfhd_segments|
    mfhd_collection[bib_id] = mfhd_segments.join('')
  end
  mfhd_collection
end

# param file_stub [String] Filename pattern
# param slice_size [Int] How many records per file
# param opts [Hash] Supply opts[:holdings] to true if a dump with
# merged holdings is wanted
# Dumps all bib records with merged holdings to MARC21
def full_bib_dump(file_stub:, slice_size:, conn:, opts: {})
  all_bibs = get_all_bib_ids(conn)
  file_num = 1
  all_bibs.each_slice(slice_size) do |bib_slice|
    file_name = "#{file_stub}-#{file_num}.mrc"
    dump_bibs_to_file(ids: bib_slice, file_name: file_name, conn: conn, opts: opts)
    file_num += 1
  end
end

### Dumps bibs to disk in batches of 1000, set opts[:holdings] to True
#     to merge holdings info
def dump_bibs_to_file(ids:, file_name:, conn:, opts: {})
  writer = MARC::Writer.new(file_name)
  writer.allow_oversized = true
  ids.each_slice(1000) do |bib_ids|
    bibs = get_bib_coll(bib_ids, conn)
    all_mfhds = get_mfhds_for_bib_coll(bib_ids, conn) if opts[:holdings]
    bibs.each do |bib|
      next unless bib['001']
      if opts[:holdings]
        bib = remove_holding_item_fields_from_bib(bib)
        bib_id = bib['001'].value.to_i
        mfhds = all_mfhds[bib_id]
        unless mfhds.nil?
          mfhd_reader = MARC::Reader.new(StringIO.new(mfhds, 'r'), external_encoding: 'UTF-8', invalid: :replace, replace: '')
          mfhd_reader.each do |holding|
            bib = merge_holding_fields_into_bib(bib: bib, holding: holding)
          end
        end
      end
      writer.write(bib)
    end
  end
  writer.close
end

### merge desired fields from holding record into attached bib
def merge_holding_fields_into_bib(bib:, holding:)
  holding.fields.each_by_tag(%w[852 866 867 868]) do |field|
    field.subfields.unshift(MARC::Subfield.new('0', holding['001'].value))
    bib.append(field)
  end
  bib
end

def merge_holding_item_fields_into_bib(bib, holding, items)
  mfhd_id = holding['001'].value
  mfhd_loc = holding['852']['b']
  bib = merge_holding_fields_into_bib(bib, holding)
  items.each do |item_id, item_info|
    item_field = MARC::DataField.new('876', ' ', ' ')
    item_field.append(MARC::Subfield.new('0', mfhd_id))
    enum_chron = merge_enum_chron(item_info[:enum], item_info[:chron])
    item_field.append(MARC::Subfield.new('3', enum_chron)) if enum_chron
    item_field.append(MARC::Subfield.new('a', item_id.to_s))
    item_field.append(MARC::Subfield.new('p', item_info[:barcode])) if item_info[:barcode]
    item_field.append(MARC::Subfield.new('t', item_info[:copy_num].to_s))
    item_field.append(MARC::Subfield.new('x', mfhd_loc))
    bib.append(item_field)
  end
  bib
end

### remove fields from bib that will be merged in from holdings and items
def remove_holding_item_fields_from_bib(bib)
  tags = %w[852 866 867 868 876]
  field_delete(tags, bib)
end

def get_auth_coll(auth_ids, conn)
  segments = get_auth_coll_segments(auth_ids, conn)
  return nil if segments.empty?
  raw_marc = segments.join('')
  MARC::Reader.new(StringIO.new(raw_marc, 'r'), external_encoding: 'UTF-8', invalid: :replace, replace: '')
end

def get_auth_coll_segments(auth_ids, conn)
  query = bulk_auth(auth_ids)
  segments = []
  conn.exec(query, *auth_ids) do |row|
    segments << row.first
  end
  segments
end

def get_all_auth_ids(conn)
  ids = []
  query = all_auth_ids
  conn.exec(query) do |row|
    ids << row.first
  end
  ids.sort
end

def dump_auths_to_file(ids, file_name, conn)
  writer = MARC::Writer.new(file_name)
  writer.allow_oversized = true
  ids.each_slice(1000) do |auth_ids|
    auths = get_auth_coll(auth_ids, conn)
    auths.each do |auth|
      writer.write(auth)
    end
  end
  writer.close
end

# param file_stub [String] Filename pattern
# param slice_size [Int] How many records per file
# Dumps all authority records to MARC21
def full_auth_dump(file_stub, slice_size, conn)
  all_auths = get_all_auth_ids(conn)
  file_num = 1
  all_auths.each_slice(slice_size) do |auth_slice|
    file_name = "#{file_stub}-#{file_num}.mrc"
    dump_auths_to_file(auth_slice, file_name, conn)
    file_num += 1
  end
end
