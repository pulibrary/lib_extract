def recap_locations
  %(
    SELECT location.location_code
    FROM location
    WHERE location.location_code LIKE 'rcp%'
  )
end

def bib_info_for_bib_ids(bib_ids)
  bib_ids = OCI8.in_cond(:bib_ids, bib_ids)
  %(
    SELECT
      bib_master.bib_id,
      bib_text.title_brief,
      bib_text.author,
      bib_text.pub_place,
      bib_text.publisher,
      bib_text.publisher_date,
      bib_text.date_type_status,
      bib_text.begin_pub_date,
      bib_text.end_pub_date,
      bib_text.edition,
      bib_text.place_code,
      bib_text.language,
      bib_text.bib_format,
      bib_master.suppress_in_opac
    FROM bib_master
      JOIN bib_text
        ON bib_master.bib_id = bib_text.bib_id
      JOIN bib_mfhd
        ON bib_text.bib_id = bib_mfhd.bib_id
      JOIN mfhd_master
        ON bib_mfhd.mfhd_id = mfhd_master.mfhd_id
    WHERE bib_master.bib_id IN (#{bib_ids.names})
    GROUP BY
      bib_master.bib_id,
      bib_text.title_brief,
      bib_text.author,
      bib_text.pub_place,
      bib_text.publisher,
      bib_text.publisher_date,
      bib_text.date_type_status,
      bib_text.begin_pub_date,
      bib_text.end_pub_date,
      bib_text.edition,
      bib_text.place_code,
      bib_text.language,
      bib_text.bib_format,
      bib_master.suppress_in_opac
    ORDER BY bib_master.bib_id
  )
end

def mfhd_info_for_bibs(bib_ids)
  bib_ids = OCI8.in_cond(:bib_ids, bib_ids)
  %(
    SELECT
      bib_mfhd.bib_id,
      mfhd_master.mfhd_id,
      location.location_code,
      mfhd_master.display_call_no,
      mfhd_master.normalized_call_no,
      GetMFHDSubfield(mfhd_master.mfhd_id, '852', 'c'),
      mfhd_master.suppress_in_opac
    FROM bib_mfhd
      JOIN mfhd_master
        ON bib_mfhd.mfhd_id = mfhd_master.mfhd_id
      JOIN location
        ON mfhd_master.location_id = location.location_id
    WHERE bib_mfhd.bib_id IN (#{bib_ids.names})
  )
end

def bib_ids_008_date1(dates)
  dates = OCI8.in_cond(:dates, dates)
  %(
    SELECT bib_master.bib_id
    FROM bib_master
      JOIN bib_text
        ON bib_master.bib_id = bib_text.bib_id
      JOIN bib_mfhd
        ON bib_text.bib_id = bib_mfhd.bib_id
      JOIN mfhd_master
        ON bib_mfhd.mfhd_id = mfhd_master.mfhd_id
    WHERE
      bib_master.suppress_in_opac = 'N'
      AND mfhd_master.suppress_in_opac = 'N'
      AND bib_text.begin_pub_date IN (#{dates.names})
    GROUP BY bib_master.bib_id
  )
end

def bib_ids_035a(values)
  values = OCI8.in_cond(:values, values)
  %(
    SELECT bib_master.bib_id
    FROM bib_master
      JOIN bib_index
        ON bib_master.bib_id = bib_index.bib_id
    WHERE
      bib_index.index_code = '0350'
      AND bib_index.display_heading IN (#{values.names})
    GROUP BY bib_master.bib_id
  )
end

def bib_ids_formats(formats)
  formats = OCI8.in_cond(:formats, formats)
  %(
    SELECT bib_master.bib_id
    FROM bib_master
      JOIN bib_mfhd
        ON bib_master.bib_id = bib_mfhd.bib_id
      JOIN mfhd_master
        ON bib_mfhd.mfhd_id = mfhd_master.mfhd_id
      JOIN bib_text
        ON bib_master.bib_id = bib_text.bib_id
    WHERE
      bib_master.suppress_in_opac = 'N'
      AND mfhd_master.suppress_in_opac = 'N'
      AND bib_text.bib_format IN (#{formats.names})
    GROUP BY bib_master.bib_id
  )
end

def all_bib_ids
  %(
    SELECT bib_master.bib_id
    FROM bib_master
      JOIN bib_mfhd
        ON bib_master.bib_id = bib_mfhd.bib_id
      JOIN mfhd_master
        ON bib_mfhd.mfhd_id = mfhd_master.mfhd_id
    WHERE
      bib_master.suppress_in_opac = 'N'
      AND mfhd_master.suppress_in_opac = 'N'
    GROUP BY bib_master.bib_id
  )
end

def bib_ids_for_locations(locations)
  locations = OCI8.in_cond(:locations, locations)
  %(
    SELECT bib_master.bib_id
    FROM bib_master
      JOIN bib_mfhd
        ON bib_master.bib_id = bib_mfhd.bib_id
      JOIN mfhd_master
        ON bib_mfhd.mfhd_id = mfhd_master.mfhd_id
      JOIN location
        ON mfhd_master.location_id = location.location_id
    WHERE
      bib_master.suppress_in_opac = 'N'
      AND mfhd_master.suppress_in_opac = 'N'
      AND location.location_code IN (#{locations.names})
    GROUP BY bib_master.bib_id
    ORDER BY bib_master.bib_id
  )
end

def bib_ids_for_items(item_ids)
  item_ids = OCI8.in_cond(:item_ids, item_ids)
  %(
    SELECT
      bib_master.bib_id,
      mfhd_item.item_id
    FROM bib_master
      JOIN bib_mfhd
        ON bib_master.bib_id = bib_mfhd.bib_id
      JOIN mfhd_item
        ON bib_mfhd.mfhd_id = mfhd_item.mfhd_id
    WHERE
      mfhd_item.item_id IN (#{item_ids.names})
    GROUP BY
      bib_master.bib_id,
      mfhd_item.item_id
  )
end

def bib_ids_orderfund_ledger
  %(
    SELECT
      bib_master.bib_id
    FROM line_item
      JOIN line_item_copy_status
        ON line_item.line_item_id = line_item_copy_status.line_item_id
      JOIN line_item_funds
        ON line_item_copy_status.copy_id = line_item_funds.copy_id
      JOIN fund reporting_fund
        ON line_item_funds.fund_id = reporting_fund.fund_id
          AND line_item_funds.ledger_id = reporting_fund.ledger_id
      JOIN ledger
        ON line_item_funds.ledger_id = ledger.ledger_id
      JOIN bib_master
        ON line_item.bib_id = bib_master.bib_id
      JOIN bib_mfhd
        ON bib_master.bib_id = bib_mfhd.bib_id
      JOIN mfhd_master
        ON bib_mfhd.mfhd_id = mfhd_master.mfhd_id
    WHERE
      ledger.ledger_name = :ledger
      AND reporting_fund.fund_code LIKE :fund_code || '%'
    GROUP BY
      bib_master.bib_id
  )
end

def bib_ids_vendor
  %(
    SELECT bib_master.bib_id
    FROM line_item
      JOIN purchase_order
        ON line_item.po_id = purchase_order.po_id
      JOIN vendor
        ON purchase_order.vendor_id = vendor.vendor_id
      JOIN bib_master
        ON line_item.bib_id = bib_master.bib_id
    WHERE vendor.vendor_code = :vendor_code
    GROUP BY bib_master.bib_id
  )
end

def bib_ids_ledger_paid
  %(
    SELECT
      bib_master.bib_id
    FROM line_item
      JOIN invoice_line_item
        ON line_item.line_item_id = invoice_line_item.line_item_id
      JOIN invoice_line_item_funds
        ON invoice_line_item.inv_line_item_id = invoice_line_item_funds.inv_line_item_id
      JOIN ledger
        ON invoice_line_item_funds.ledger_id = ledger.ledger_id
      JOIN invoice
        ON invoice_line_item.invoice_id = invoice.invoice_id
      JOIN bib_master
        ON line_item.bib_id = bib_master.bib_id
      JOIN bib_mfhd
        ON bib_master.bib_id = bib_mfhd.bib_id
      JOIN mfhd_master
        ON bib_mfhd.mfhd_id = mfhd_master.mfhd_id
    WHERE
      ledger.ledger_name = :ledger
      AND invoice.invoice_status = 1
    GROUP BY
      bib_master.bib_id
  )
end

def mfhd_ids_ledger_paid
  %(
    SELECT
      line_item_copy_status.mfhd_id
    FROM line_item_copy_status
      JOIN invoice_line_item
        ON line_item_copy_status.line_item_id = invoice_line_item.line_item_id
      JOIN invoice_line_item_funds
        ON invoice_line_item.inv_line_item_id = invoice_line_item_funds.inv_line_item_id
      JOIN ledger
        ON invoice_line_item_funds.ledger_id = ledger.ledger_id
      JOIN invoice
        ON invoice_line_item.invoice_id = invoice.invoice_id
    WHERE
      ledger.ledger_name = :ledger
      AND invoice.invoice_status = 1
    GROUP BY
      line_item_copy_status.mfhd_id
  )
end

def bib_ids_location
  %(
    SELECT
      bib_master.bib_id
    FROM bib_master
      JOIN bib_mfhd
        ON bib_master.bib_id = bib_mfhd.bib_id
      JOIN mfhd_master
        ON bib_mfhd.mfhd_id = mfhd_master.mfhd_id
      JOIN location
        ON mfhd_master.location_id = location.location_id
    WHERE
      bib_master.suppress_in_opac = 'N'
      AND mfhd_master.suppress_in_opac = 'N'
      AND location.location_code = :location
    GROUP BY
      bib_master.bib_id
  )
end

def mfhd_info_callnum
  %(
    SELECT
      bib_master.bib_id,
      mfhd_master.mfhd_id,
      location.location_code,
      mfhd_master.display_call_no,
      mfhd_master.normalized_call_no,
      GetMFHDSubfield(mfhd_master.mfhd_id, '852', 'c')
    FROM bib_master
      JOIN bib_mfhd
        ON bib_master.bib_id = bib_mfhd.bib_id
      JOIN mfhd_master
        ON bib_mfhd.mfhd_id = mfhd_master.mfhd_id
      JOIN location
        ON mfhd_master.location_id = location.location_id
    WHERE
      bib_master.suppress_in_opac = 'N'
      AND mfhd_master.suppress_in_opac = 'N'
      AND mfhd_master.display_call_no LIKE :pattern || '%'
    GROUP BY
      bib_master.bib_id,
      mfhd_master.mfhd_id,
      location.location_code,
      mfhd_master.display_call_no,
      mfhd_master.normalized_call_no,
      GetMFHDSubfield(mfhd_master.mfhd_id, '852', 'c')
  )
end

def bib_ids_callnum
  %(
    SELECT
      bib_master.bib_id
    FROM bib_master
      JOIN bib_mfhd
        ON bib_master.bib_id = bib_mfhd.bib_id
      JOIN mfhd_master
        ON bib_mfhd.mfhd_id = mfhd_master.mfhd_id
    WHERE
      bib_master.suppress_in_opac = 'N'
      AND mfhd_master.suppress_in_opac = 'N'
      AND mfhd_master.display_call_no LIKE :pattern || '%'
    GROUP BY
      bib_master.bib_id
  )
end

def bib_ids_languages_dates(languages, date1, date2)
  languages = OCI8.in_cond(:languages, languages)
  %(
    SELECT
      bib_master.bib_id
    FROM bib_master
      JOIN bib_text
        ON bib_master.bib_id = bib_text.bib_id
      JOIN bib_mfhd
        ON bib_text.bib_id = bib_mfhd.bib_id
      JOIN mfhd_master
        ON bib_mfhd.mfhd_id = mfhd_master.mfhd_id
    WHERE
      bib_master.suppress_in_opac = 'N'
      AND mfhd_master.suppress_in_opac = 'N'
      AND bib_text.language IN (#{languages.names})
      AND bib_master.create_date >= TO_DATE('#{date1}', 'mm-dd-yyyy')
      AND bib_master.create_date < TO_DATE('#{date2}', 'mm-dd-yyyy')
    GROUP BY
      bib_master.bib_id
  )
end

def bib_info_location_callnum
  %(
    SELECT
      bib_master.bib_id
    FROM bib_master
      JOIN bib_mfhd
        ON bib_master.bib_id = bib_mfhd.bib_id
      JOIN mfhd_master
        ON bib_mfhd.mfhd_id = mfhd_master.mfhd_id
      JOIN location
        ON mfhd_master.location_id = location.location_id
    WHERE
      bib_master.suppress_in_opac = 'N'
      AND mfhd_master.suppress_in_opac = 'N'
      AND location.location_code = :location
      AND mfhd_master.display_call_no LIKE :pattern || '%'
    GROUP BY
      bib_master.bib_id
  )
end

def bib_std_nos(bib_ids)
  bib_ids = OCI8.in_cond(:bib_ids, bib_ids)
  %(
    SELECT
      bib_index.bib_id,
      bib_index.index_code,
      bib_index.display_heading
    FROM bib_index
    WHERE
      bib_index.bib_id IN (#{bib_ids.names})
      AND bib_index.index_code IN ('010A', '020A', '022A', '022L', '0350')
    ORDER BY
      bib_index.bib_id,
      bib_index.index_code,
      bib_index.display_heading
  )
end

def holdings_notes
  %(
    SELECT
      GetAllMFHDTag(mfhd_data.mfhd_id, '866', 2)
    FROM mfhd_data
    WHERE mfhd_data.mfhd_id = :mfhd_id
    GROUP BY
      GetAllMFHDTag(mfhd_data.mfhd_id, '866', 2)
  )
end

def physical_descriptions(bib_ids)
  bib_ids = OCI8.in_cond(:bib_ids, bib_ids)
  %(
    SELECT
      bib_data.bib_id,
      GetAllBIBTag(bib_data.bib_id, '300')
    FROM bib_data
    WHERE
      bib_data.bib_id IN (#{bib_ids.names})
  )
end
