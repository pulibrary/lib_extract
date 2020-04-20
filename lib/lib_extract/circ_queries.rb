def circ_locations_archive
  %(
    SELECT
      location.location_id,
      location.location_code,
      location.location_name
    FROM location
      JOIN circ_trans_archive
        ON location.location_id = circ_trans_archive.charge_location
    GROUP BY
      location.location_id,
      location.location_code,
      location.location_name
  )
end

def circ_locations_current
  %(
    SELECT
      location.location_id,
      location.location_code,
      location.location_name
    FROM location
      JOIN circ_transactions
        ON location.location_id = circ_transactions.charge_location
    GROUP BY
      location.location_id,
      location.location_code,
      location.location_name
  )
end

def current_circ_by_circloc_dates_null_item
  %(
    SELECT
      circ_transactions.circ_transaction_id,
      circ_transactions.item_id,
      patron_group.patron_group_code,
      circ_transactions.charge_date,
      circ_transactions.renewal_count,
      item_type.item_type_code
    FROM circ_transactions
      JOIN patron_group
        ON circ_transactions.patron_group_id = patron_group.patron_group_id
      JOIN circ_policy_matrix
        ON circ_transactions.circ_policy_matrix_id = circ_policy_matrix.circ_policy_matrix_id
      JOIN item_type
        ON circ_policy_matrix.item_type_id = item_type.item_type_id
      JOIN location
        ON circ_transactions.charge_location = location.location_id
      LEFT JOIN item
        ON circ_transactions.item_id = item.item_id
    WHERE
      location.location_code = :location_code
      AND circ_transactions.charge_date >= TO_DATE(:date1, 'mm-dd-yyyy')
      AND circ_transactions.charge_date < TO_DATE(:date2, 'mm-dd-yyyy')
      AND item.item_id IS NULL
  )
end

def current_circ_by_circloc_dates
  %(
    SELECT
      circ_transactions.circ_transaction_id,
      circ_transactions.item_id,
      patron_group.patron_group_code,
      circ_transactions.charge_date,
      circ_transactions.renewal_count,
      item_type.item_type_code
    FROM circ_transactions
      JOIN patron_group
        ON circ_transactions.patron_group_id = patron_group.patron_group_id
      JOIN item
        ON circ_transactions.item_id = item.item_id
      JOIN item_type
        ON item.item_type_id = item_type.item_type_id
      JOIN location
        ON circ_transactions.charge_location = location.location_id
    WHERE
      location.location_code = :location_code
      AND circ_transactions.charge_date >= TO_DATE(:date1, 'mm-dd-yyyy')
      AND circ_transactions.charge_date < TO_DATE(:date2, 'mm-dd-yyyy')
  )
end

def archive_circ_by_circloc_dates
  %(
    SELECT
      circ_trans_archive.circ_transaction_id,
      circ_trans_archive.item_id,
      patron_group.patron_group_code,
      circ_trans_archive.charge_date,
      circ_trans_archive.renewal_count,
      item_type.item_type_code
      FROM circ_trans_archive
        JOIN patron_group
          ON circ_trans_archive.patron_group_id = patron_group.patron_group_id
        JOIN item
          ON circ_trans_archive.item_id = item.item_id
        JOIN item_type
          ON item.item_type_id = item_type.item_type_id
        JOIN location
          ON circ_trans_archive.charge_location = location.location_id
    WHERE
      location.location_code = :location_code
      AND circ_trans_archive.charge_date >= TO_DATE(:date1, 'mm-dd-yyyy')
      AND circ_trans_archive.charge_date < TO_DATE(:date2, 'mm-dd-yyyy')
  )
end

def archive_circ_by_circloc_dates_null_item
  %(
      SELECT
        circ_trans_archive.circ_transaction_id,
        circ_trans_archive.item_id,
        patron_group.patron_group_code,
        circ_trans_archive.charge_date,
        circ_trans_archive.renewal_count,
        item_type.item_type_code
      FROM circ_trans_archive
        JOIN patron_group
          ON circ_trans_archive.patron_group_id = patron_group.patron_group_id
        JOIN circ_policy_matrix
          ON circ_trans_archive.circ_policy_matrix_id = circ_policy_matrix.circ_policy_matrix_id
        JOIN item_type
          ON circ_policy_matrix.item_type_id = item_type.item_type_id
        JOIN location
          ON circ_trans_archive.charge_location = location.location_id
        LEFT JOIN item
          ON circ_trans_archive.item_id = item.item_id
      WHERE
        location.location_code = :location_code
        AND circ_trans_archive.charge_date >= TO_DATE(:date1, 'mm-dd-yyyy')
        AND circ_trans_archive.charge_date < TO_DATE(:date2, 'mm-dd-yyyy')
        AND item.item_id IS NULL
  )
end

def current_circ_items_lang_date
  %(
    SELECT
      circ_transactions.item_id
    FROM circ_transactions
      JOIN mfhd_item
        ON circ_transactions.item_id = mfhd_item.item_id
      JOIN bib_mfhd
        ON mfhd_item.mfhd_id = bib_mfhd.mfhd_id
      JOIN bib_text
        ON bib_mfhd.bib_id = bib_text.bib_id
    WHERE
      bib_text.language = :language
      AND circ_transactions.charge_date > TO_DATE(:date1, 'mm-dd-yyyy')
      AND circ_transactions.charge_date <= TO_DATE(:date2, 'mm-dd-yyyy')
    GROUP BY
      circ_transactions.item_id
  )
end

def archive_circ_items_lang_date
  %(
    SELECT
      circ_trans_archive.item_id
    FROM circ_trans_archive
      JOIN mfhd_item
        ON circ_trans_archive.item_id = mfhd_item.item_id
      JOIN bib_mfhd
        ON mfhd_item.mfhd_id = bib_mfhd.mfhd_id
      JOIN bib_text
        ON bib_mfhd.bib_id = bib_text.bib_id
    WHERE
      bib_text.language = :language
      AND circ_trans_archive.charge_date > TO_DATE(:date1, 'mm-dd-yyyy')
      AND circ_trans_archive.charge_date <= TO_DATE(:date2, 'mm-dd-yyyy')
  )
end

def current_circ_by_bib
  %(
    SELECT
      circ_transactions.circ_transaction_id,
      circ_transactions.item_id,
      patron_group.patron_group_code,
      circ_transactions.charge_date,
      circ_transactions.renewal_count,
      item_type.item_type_code
    FROM circ_transactions
      JOIN patron_group
        ON circ_transactions.patron_group_id = patron_group.patron_group_id
      JOIN item
        ON circ_transactions.item_id = item.item_id
      JOIN mfhd_item
        ON item.item_id = mfhd_item.item_id
      JOIN bib_mfhd
        ON mfhd_item.mfhd_id = bib_mfhd.mfhd_id
      JOIN item_type
        ON item.item_type_id = item_type.item_type_id
    WHERE bib_mfhd.bib_id = :bib_id
    GROUP BY
      circ_transactions.circ_transaction_id,
      circ_transactions.item_id,
      patron_group.patron_group_code,
      circ_transactions.charge_date,
      circ_transactions.renewal_count,
      item_type.item_type_code
  )
end

def archive_circ_by_bib
  %(
    SELECT
      circ_trans_archive.circ_transaction_id,
      circ_trans_archive.item_id,
      patron_group.patron_group_code,
      circ_trans_archive.charge_date,
      circ_trans_archive.renewal_count,
      item_type.item_type_code
    FROM circ_trans_archive
      JOIN patron_group
        ON circ_trans_archive.patron_group_id = patron_group.patron_group_id
      JOIN item
        ON circ_trans_archive.item_id = item.item_id
      JOIN mfhd_item
        ON item.item_id = mfhd_item.item_id
      JOIN bib_mfhd
        ON mfhd_item.mfhd_id = bib_mfhd.mfhd_id
      JOIN item_type
        ON item.item_type_id = item_type.item_type_id
    WHERE bib_mfhd.bib_id = :bib_id
    GROUP BY
    circ_trans_archive.circ_transaction_id,
    circ_trans_archive.item_id,
    patron_group.patron_group_code,
    circ_trans_archive.charge_date,
    circ_trans_archive.renewal_count,
    item_type.item_type_code
  )
end

def current_circ_total_by_bib
  %(
    SELECT COUNT(circ_transactions.circ_transaction_id)
    FROM circ_transactions
      JOIN mfhd_item
        ON circ_transactions.item_id = mfhd_item.item_id
      JOIN bib_mfhd
        ON mfhd_item.mfhd_id = bib_mfhd.bib_id
    WHERE bib_mfhd.bib_id = :bib_id
  )
end

def archive_circ_total_by_bib
  %(
    SELECT COUNT(circ_trans_archive.circ_transaction_id)
    FROM circ_trans_archive
      JOIN mfhd_item
        ON circ_trans_archive.item_id = mfhd_item.item_id
      JOIN bib_mfhd
        ON mfhd_item.mfhd_id = bib_mfhd.bib_id
    WHERE bib_mfhd.bib_id = :bib_id
  )
end

def current_circ_by_mfhds(mfhd_ids, date1, date2)
  mfhd_ids = OCI8.in_cond(:mfhd_ids, mfhd_ids)
  %(
    SELECT
      mfhd_item.mfhd_id,
      circ_transactions.circ_transaction_id,
      circ_transactions.item_id,
      patron_group.patron_group_code,
      circ_transactions.charge_date,
      circ_transactions.renewal_count,
      item_type.item_type_code
    FROM circ_transactions
      JOIN patron_group
        ON circ_transactions.patron_group_id = patron_group.patron_group_id
      JOIN item
        ON circ_transactions.item_id = item.item_id
      JOIN mfhd_item
        ON item.item_id = mfhd_item.item_id
      JOIN item_type
        ON item.item_type_id = item_type.item_type_id
    WHERE
      mfhd_item.mfhd_id IN (#{mfhd_ids.names})
      AND circ_transactions.charge_date >= TO_DATE('#{date1}', 'mm-dd-yyyy')
      AND circ_transactions.charge_date < TO_DATE('#{date2}', 'mm-dd-yyyy')
    GROUP BY
      mfhd_item.mfhd_id,
      circ_transactions.circ_transaction_id,
      circ_transactions.item_id,
      patron_group.patron_group_code,
      circ_transactions.charge_date,
      circ_transactions.renewal_count,
      item_type.item_type_code
  )
end

def archive_circ_by_mfhds(mfhd_ids, date1, date2)
  mfhd_ids = OCI8.in_cond(:mfhd_ids, mfhd_ids)
  %(
    SELECT
    mfhd_item.mfhd_id,
    circ_trans_archive.circ_transaction_id,
    circ_trans_archive.item_id,
    patron_group.patron_group_code,
    circ_trans_archive.charge_date,
    circ_trans_archive.renewal_count,
    item_type.item_type_code
  FROM circ_trans_archive
    JOIN patron_group
      ON circ_trans_archive.patron_group_id = patron_group.patron_group_id
    JOIN item
      ON circ_trans_archive.item_id = item.item_id
    JOIN mfhd_item
      ON item.item_id = mfhd_item.item_id
    JOIN item_type
      ON item.item_type_id = item_type.item_type_id
  WHERE
    mfhd_item.mfhd_id IN (#{mfhd_ids.names})
    AND circ_trans_archive.charge_date >= TO_DATE('#{date1}', 'mm-dd-yyyy')
    AND circ_trans_archive.charge_date < TO_DATE('#{date2}', 'mm-dd-yyyy')
  GROUP BY
    mfhd_item.mfhd_id,
    circ_trans_archive.circ_transaction_id,
    circ_trans_archive.item_id,
    patron_group.patron_group_code,
    circ_trans_archive.charge_date,
    circ_trans_archive.renewal_count,
    item_type.item_type_code
  )
end

def current_circ_for_items(item_ids, date1, date2)
  item_ids = OCI8.in_cond(:item_ids, item_ids)
  %(
    SELECT
      circ_transactions.item_id,
      circ_transactions.circ_transaction_id,
      patron_group.patron_group_code,
      circ_transactions.charge_date,
      circ_transactions.discharge_date,
      circ_transactions.renewal_count,
      item_type.item_type_code
    FROM circ_transactions
      JOIN patron_group
        ON circ_transactions.patron_group_id = patron_group.patron_group_id
      JOIN item
        ON circ_transactions.item_id = item.item_id
      JOIN item_type
        ON item.item_type_id = item_type.item_type_id
    WHERE
      circ_transactions.item_id IN (#{item_ids.names})
      AND circ_transactions.charge_date >= TO_DATE('#{date1}', 'mm-dd-yyyy')
      AND circ_transactions.charge_date < TO_DATE('#{date2}', 'mm-dd-yyyy')
  )
end

def archive_circ_for_items(item_ids, date1, date2)
  item_ids = OCI8.in_cond(:item_ids, item_ids)
  %(
    SELECT
      circ_trans_archive.item_id,
      circ_trans_archive.circ_transaction_id,
      patron_group.patron_group_code,
      circ_trans_archive.charge_date,
      circ_trans_archive.discharge_date,
      circ_trans_archive.renewal_count,
      item_type.item_type_code
    FROM circ_trans_archive
      JOIN patron_group
        ON circ_trans_archive.patron_group_id = patron_group.patron_group_id
      JOIN item
        ON circ_trans_archive.item_id = item.item_id
      JOIN item_type
        ON item.item_type_id = item_type.item_type_id
    WHERE
      circ_trans_archive.item_id IN (#{item_ids.names})
      AND circ_trans_archive.charge_date >= TO_DATE('#{date1}', 'mm-dd-yyyy')
      AND circ_trans_archive.charge_date < TO_DATE('#{date2}', 'mm-dd-yyyy')
  )
end

def current_holds_by_items(item_ids, date1, date2)
  item_ids = OCI8.in_cond(:item_ids, item_ids)
  %(
    SELECT
      hold_recall_items.item_id,
      hold_recall_items.hold_recall_id,
      hold_recall.hold_recall_type,
      location.location_code,
      hold_recall.expire_date,
      hold_recall.create_date,
      patron_group.patron_group_code
    FROM hold_recall_items
      JOIN hold_recall
        ON hold_recall_items.hold_recall_id = hold_recall.hold_recall_id
      JOIN location
        ON hold_recall.pickup_location = location.location_id
      LEFT JOIN patron_group
        ON hold_recall.patron_group_id = patron_group.patron_group_id
    WHERE
      hold_recall_items.item_id IN (#{item_ids.names})
      AND hold_recall.expire_date >= TO_DATE('#{date1}', 'mm-dd-yyyy')
      AND hold_recall.expire_date < TO_DATE('#{date2}', 'mm-dd-yyyy')
    GROUP BY
      hold_recall_items.item_id,
      hold_recall_items.hold_recall_id,
      hold_recall.hold_recall_type,
      location.location_code,
      hold_recall.expire_date,
      hold_recall.create_date,
      patron_group.patron_group_code
  )
end

def archive_holds_by_items(item_ids, date1, date2)
  item_ids = OCI8.in_cond(:item_ids, item_ids)
  %(
    SELECT
      hold_recall_item_archive.item_id,
      hold_recall_item_archive.hold_recall_id,
      hold_recall_archive.hold_recall_type,
      location.location_code,
      hold_recall_archive.expire_date,
      hold_recall_archive.create_date,
      patron_group.patron_group_code
    FROM hold_recall_item_archive
      JOIN hold_recall_archive
        ON hold_recall_item_archive.hold_recall_id = hold_recall_archive.hold_recall_id
      JOIN location
        ON hold_recall_archive.pickup_location = location.location_id
      LEFT JOIN patron_group
        ON hold_recall_archive.patron_group_id = patron_group.patron_group_id
    WHERE
      hold_recall_item_archive.item_id IN (#{item_ids.names})
      AND hold_recall_archive.expire_date >= TO_DATE('#{date1}', 'mm-dd-yyyy')
      AND hold_recall_archive.expire_date < TO_DATE('#{date2}', 'mm-dd-yyyy')
    GROUP BY
      hold_recall_item_archive.item_id,
      hold_recall_item_archive.hold_recall_id,
      hold_recall_archive.hold_recall_type,
      location.location_code,
      hold_recall_archive.expire_date,
      hold_recall_archive.create_date,
      patron_group.patron_group_code
  )
end
