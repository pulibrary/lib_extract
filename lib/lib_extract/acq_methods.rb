### Convert a cost to local currency using an arbitrary conversion rate
def convert_currency(conversion_rate, cost)
  if conversion_rate.zero?
    format('%.2f', (cost / 100.0))
  else
    format('%.2f', (cost * 1000.0 / conversion_rate))
  end
end

### Retrieve all invoices for an array of bib IDs
#     Performs currency conversion as well
def get_all_payment_info_by_bibs(bib_ids, conn)
  results = {}
  bib_ids.each_slice(1000) do |segment|
    query = payment_info_by_bibs_all_ledgers(segment)
    conn.exec(query, *segment) do |row|
      hash = {}
      bib_id = row[0]
      hash[:invoice_id] = row[1]
      hash[:vendor_code] = row[2]
      hash[:invoice_num] = row[3]
      hash[:voucher_num] = row[4]
      hash[:invoice_status] = row[5]
      hash[:status_date] = row[6]
      hash[:invoice_date] = row[7]
      hash[:conversion_rate] = row[8]
      hash[:reporting_fund] = row[9]
      hash[:allocated_fund] = row[10]
      hash[:invoice_line_amount] = row[11]
      hash[:percentage] = row[12]
      cost_share = hash[:invoice_line_amount] * (hash[:percentage] / 100_000_000.0)
      converted_cost_share = convert_currency(hash[:conversion_rate], cost_share)
      converted_total = convert_currency(hash[:conversion_rate], hash[:invoice_line_amount])
      hash[:converted_inv_line_amount] = converted_total
      hash[:converted_cost_share] = converted_cost_share
      hash[:account_number] = row[13]
      hash[:ledger] = row[14]
      hash[:fiscal_period] = row[15]
      results[bib_id] = [] unless results[bib_id]
      results[bib_id] << hash
    end
  end
  results
end

### Retrieve invoice info on a given array of ledgers for an array of MFHD IDs;
#     Performs currency conversion as well
def get_payment_info_by_mfhds_ledgers(mfhd_ids, ledgers, conn)
  results = {}
  ledgers.each do |ledger|
    mfhd_ids.each_slice(1000) do |segment|
      query = payment_info_by_mfhds(segment, ledger)
      conn.exec(query, *segment) do |row|
        hash = {}
        mfhd_id = row.shift
        results[mfhd_id] = [] unless results[mfhd_id]
        hash[:invoice_id] = row.shift
        hash[:vendor_code] = row.shift
        hash[:invoice_num] = row.shift
        hash[:voucher_num] = row.shift
        hash[:invoice_status] = row.shift
        hash[:status_date] = row.shift
        hash[:invoice_date] = row.shift
        hash[:conversion_rate] = row.shift
        hash[:reporting_fund] = row.shift
        hash[:allocated_fund] = row.shift
        hash[:invoice_line_amount] = row.shift
        hash[:percentage] = row.shift
        cost_share = hash[:invoice_line_amount] * (hash[:percentage] / 100_000_000.0)
        converted_cost_share = convert_currency(hash[:conversion_rate], cost_share)
        converted_total = convert_currency(hash[:conversion_rate], hash[:invoice_line_amount])
        hash[:converted_inv_line_amount] = converted_total
        hash[:converted_cost_share] = converted_cost_share
        hash[:account_number] = row.shift
        hash[:ledger] = row.shift
        results[mfhd_id] << hash
      end
    end
  end
  results
end

### Retrieve invoice info on a given ledger for an array of bib IDs;
#     Performs currency conversion as well
def get_payment_info_by_bibs_ledger(bib_ids, ledger, conn)
  results = {}
  bib_ids.each_slice(1000) do |segment|
    query = payment_info_by_bibs(segment, ledger)
    conn.exec(query, *segment) do |row|
      hash = {}
      bib_id = row[0]
      hash[:invoice_id] = row[1]
      hash[:vendor_code] = row[2]
      hash[:invoice_num] = row[3]
      hash[:voucher_num] = row[4]
      hash[:invoice_status] = row[5]
      hash[:status_date] = row[6]
      hash[:invoice_date] = row[7]
      hash[:conversion_rate] = row[8]
      hash[:reporting_fund] = row[9]
      hash[:allocated_fund] = row[10]
      hash[:invoice_line_amount] = row[11]
      hash[:percentage] = row[12]
      cost_share = hash[:invoice_line_amount] * (hash[:percentage] / 100_000_000.0)
      converted_cost_share = convert_currency(hash[:conversion_rate], cost_share)
      converted_total = convert_currency(hash[:conversion_rate], hash[:invoice_line_amount])
      hash[:converted_inv_line_amount] = converted_total
      hash[:converted_cost_share] = converted_cost_share
      hash[:account_number] = row[13]
      hash[:ledger] = row[14]
      results[bib_id] = [] unless results[bib_id]
      results[bib_id] << hash
    end
  end
  results
end

### Get PO info for a group of MFHD IDs
def get_order_info_by_mfhds(mfhd_ids, conn)
  results = {}
  mfhd_ids.each_slice(1000) do |segment|
    query = order_info_by_mfhds(segment)
    conn.exec(query, *segment) do |row|
      hash = {}
      mfhd_id = row.shift
      hash[:po_num] = row.shift
      hash[:po_type] = row.shift
      hash[:po_approve_date] = row.shift
      hash[:po_id] = row.shift
      hash[:po_status] = row.shift
      hash[:line_item_id] = row.shift
      hash[:conversion_rate] = row.shift
      hash[:line_item_status] = row.shift
      hash[:reporting_fund] = row.shift
      hash[:allocated_fund] = row.shift
      hash[:po_line_amount] = row.shift
      hash[:percentage] = row.shift
      hash[:ledger] = row.shift
      cost_share = hash[:po_line_amount] * (hash[:percentage] / 100_000_000.0)
      converted_total = convert_currency(hash[:conversion_rate], hash[:po_line_amount])
      converted_cost_share = convert_currency(hash[:conversion_rate], cost_share)
      hash[:converted_po_line_amount] = converted_total
      hash[:converted_cost_share] = converted_cost_share
      results[mfhd_id] = [] unless results[mfhd_id]
      results[mfhd_id] << hash
    end
  end
  results
end

### Get PO info for a group of bib IDs
def get_order_info_by_bibs(bib_ids, conn)
  results = {}
  bib_ids.each_slice(1000) do |segment|
    query = order_info_by_bibs(segment)
    conn.exec(query, *segment) do |row|
      hash = {}
      bib_id = row[0]
      hash[:po_num] = row[1]
      hash[:po_approve_date] = row[2]
      hash[:po_id] = row[3]
      hash[:po_status] = row[4]
      hash[:line_item_id] = row[5]
      hash[:conversion_rate] = row[6]
      hash[:line_item_status] = row[7]
      hash[:reporting_fund] = row[8]
      hash[:allocated_fund] = row[9]
      hash[:po_line_amount] = row[10]
      hash[:ledger] = row[11]
      results[bib_id] = [] unless results[bib_id]
      results[bib_id] << hash
    end
  end
  results
end
