def item_statuses_for_mfhd
  %(
    SELECT
      item_status_desc
    FROM mfhd_item
      JOIN item_status
        ON mfhd_item.item_id = item_status.item_id
      JOIN item_status_type
        ON item_status.item_status = item_status_type.item_status_type
    WHERE mfhd_item.mfhd_id = :mfhd_id
    GROUP BY item_status_desc
  )
end

def item_info_for_item_ids(item_ids)
  item_ids = OCI8.in_cond(:item_ids, item_ids)
  %(
    SELECT
      item.item_id,
      perm_type.item_type_code,
      temp_type.item_type_code,
      item.create_date,
      item.modify_date,
      perm_loc.location_code,
      temp_loc.location_code,
      item.on_reserve,
      item_barcode.item_barcode,
      mfhd_item.item_enum,
      mfhd_item.chron,
      item.copy_number
    FROM item
      JOIN item_type perm_type
        ON item.item_type_id = perm_type.item_type_id
      JOIN location perm_loc
        ON item.perm_location = perm_loc.location_id
      JOIN mfhd_item
        ON item.item_id = mfhd_item.item_id
      LEFT JOIN item_barcode
        ON item.item_id = item_barcode.item_id
      LEFT JOIN item_type temp_type
        ON item.temp_item_type_id = temp_type.item_type_id
      LEFT JOIN location temp_loc
        ON item.temp_location = temp_loc.location_id
    WHERE item.item_id IN (#{item_ids.names})
  )
end

def items_for_patron
  %(
    SELECT item_id
    FROM circ_transactions
    WHERE
      patron_id = :patron_id
      AND circ_transactions.current_due_date < TO_DATE(:due_date, 'mm-dd-yyyy')
    ORDER BY item_id
  )
end

### Does not return items without active barcodes
def items_by_perm_type_create_date
  %(
    SELECT item.item_id
    FROM item
      JOIN item_type perm_type
        ON item.item_type_id = perm_type.item_type_id
    WHERE
      perm_type.item_type_code = :perm_type
      AND item.create_date >= TO_DATE(:date1, 'mm-dd-yyyy')
      AND item.create_date < TO_DATE(:date2, 'mm-dd-yyyy')
  )
end

def items_circulated_current_dates
  %(
    SELECT item.item_id
    FROM item
      JOIN circ_transactions
        ON item.item_id = circ_transactions.item_id
    WHERE
      circ_transactions.charge_date >= TO_DATE(:date1, 'mm-dd-yyyy')
      AND circ_transactions.charge_date < TO_DATE(:date2, 'mm-dd-yyyy')
    GROUP BY item.item_id
  )
end

def items_circulated_archive_dates
  %(
    SELECT item.item_id
    FROM item
      JOIN circ_trans_archive
        ON item.item_id = circ_trans_archive.item_id
    WHERE
      circ_trans_archive.charge_date >= TO_DATE(:date1, 'mm-dd-yyyy')
      AND circ_trans_archive.charge_date < TO_DATE(:date2, 'mm-dd-yyyy')
    GROUP BY item.item_id
  )
end

def bib_info_for_circulated_items(item_ids)
  item_ids = OCI8.in_cond(:item_ids, item_ids)
  %(
    SELECT
      bib_master.bib_id,
      bib_text.title_brief,
      bib_text.author,
      mfhd_master.mfhd_id,
      location.location_code,
      location.location_name,
      location.location_display_name,
      mfhd_master.display_call_no,
      mfhd_item.item_enum,
      mfhd_item.chron,
      item_barcode.item_barcode,
      mfhd_item.item_id,
      circ_transactions.current_due_date
    FROM bib_master
      JOIN bib_text
        ON bib_master.bib_id = bib_text.bib_id
      JOIN bib_mfhd
        ON bib_text.bib_id = bib_mfhd.bib_id
      JOIN mfhd_master
        ON bib_mfhd.mfhd_id = mfhd_master.mfhd_id
      JOIN location
        ON mfhd_master.location_id = location.location_id
      JOIN mfhd_item
        ON mfhd_master.mfhd_id = mfhd_item.mfhd_id
      JOIN item_barcode
        ON mfhd_item.item_id = item_barcode.item_id
      LEFT JOIN circ_transactions
        ON mfhd_item.item_id = circ_transactions.item_id
    WHERE
      mfhd_item.item_id IN (#{item_ids.names})
      AND item_barcode.barcode_status = 1
    GROUP BY
      bib_master.bib_id,
      bib_text.title_brief,
      bib_text.author,
      mfhd_master.mfhd_id,
      location.location_code,
      location.location_name,
      location.location_display_name,
      mfhd_master.display_call_no,
      mfhd_item.item_enum,
      mfhd_item.chron,
      item_barcode.item_barcode,
      mfhd_item.item_id,
      circ_transactions.current_due_date
    ORDER BY
      bib_text.title_brief,
      mfhd_item.item_enum,
      mfhd_item.chron
  )
end

def items_for_mfhds(mfhd_ids)
  mfhd_ids = OCI8.in_cond(:mfhd_ids, mfhd_ids)
  %(
    SELECT
      mfhd_item.mfhd_id,
      item.item_id
    FROM item
      JOIN mfhd_item
        ON item.item_id = mfhd_item.item_id
    WHERE
      mfhd_item.mfhd_id IN (#{mfhd_ids.names})
  )
end

def current_periodicals
  %(
  SELECT
    serial_issues.enumchron
  FROM subscription
    JOIN component
      ON subscription.subscription_id = component.subscription_id
    JOIN issues_received
      ON component.component_id = issues_received.component_id
    JOIN serial_issues
      ON issues_received.component_id = serial_issues.component_id
        AND issues_received.issue_id = serial_issues.issue_id
    JOIN line_item_copy_status
      ON subscription.line_item_id = line_item_copy_status.line_item_id
    JOIN line_item
      ON line_item_copy_status.line_item_id = line_item.line_item_id
  WHERE
    line_item_copy_status.mfhd_id = :mfhd_id
    AND serial_issues.received = 1
    AND issues_received.opac_suppressed = 1
  ORDER BY serial_issues.component_id DESC, serial_issues.issue_id DESC
  )
end
