def patron_info(patron_ids)
  patron_ids = OCI8.in_cond(:patron_ids, patron_ids)
  %(
    SELECT
      patron.patron_id,
      patron.title,
      patron.institution_id,
      patron.last_name,
      patron.first_name,
      patron.middle_name,
      patron.expire_date,
      patron.purge_date,
      patron.major,
      patron.department
    FROM patron
    WHERE patron.patron_id IN (#{patron_ids.names})
  )
end

def active_patron_barcodes(patron_ids)
  patron_ids = OCI8.in_cond(:patron_ids, patron_ids)
  %(
    SELECT
      patron_barcode.patron_id,
      patron_barcode.patron_barcode,
      patron_group.patron_group_code
    FROM patron_barcode
      JOIN patron_group
        ON patron_barcode.patron_group_id = patron_group.patron_group_id
    WHERE
      patron_barcode.barcode_status = 1
      AND patron_barcode.patron_id IN (#{patron_ids.names})
    GROUP BY
      patron_barcode.patron_id,
      patron_barcode.patron_barcode,
      patron_group.patron_group_code
  )
end

def current_patrons_with_charged_items
  %(
    SELECT
      patron.patron_id
    FROM patron
      JOIN patron_barcode
        ON patron.patron_id = patron_barcode.patron_id
      JOIN patron_group
        ON patron_barcode.patron_group_id = patron_group.patron_group_id
      JOIN circ_transactions
        ON patron.patron_id = circ_transactions.patron_id
    WHERE
      patron.purge_date >= TO_DATE(:purge_date, 'mm-dd-yyyy')
      AND circ_transactions.current_due_date < TO_DATE(:due_date, 'mm-dd-yyyy')
      AND patron_barcode.barcode_status = 1
    GROUP BY
      patron.patron_id
  )
end

def patron_email_addresses(patron_ids)
  patron_ids = OCI8.in_cond(:patron_ids, patron_ids)
  %(
    SELECT
      patron_id,
      address_line1,
      expire_date,
      effect_date
    FROM patron_address
    WHERE
      patron_id IN (#{patron_ids.names})
      AND address_type = 3
  )
end
