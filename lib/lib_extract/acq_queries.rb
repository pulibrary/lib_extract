def order_info_by_mfhds(mfhd_ids)
  mfhd_ids = OCI8.in_cond(:mfhd_ids, mfhd_ids)
  %(
    SELECT
      line_item_copy_status.mfhd_id,
      purchase_order.po_number,
      po_type.po_type_desc,
      purchase_order.po_approve_date,
      purchase_order.po_id,
      po_status.po_status_desc,
      line_item.line_item_id,
      purchase_order.conversion_rate,
      line_item_status.line_item_status_desc,
      reporting_fund.fund_code,
      allocated_fund.fund_code,
      line_item_funds.amount,
      line_item_funds.percentage,
      ledger.ledger_name
    FROM line_item
      JOIN purchase_order
        ON line_item.po_id = purchase_order.po_id
      JOIN po_status
        ON purchase_order.po_status = po_status.po_status
      JOIN line_item_copy_status
        ON line_item.line_item_id = line_item_copy_status.line_item_id
      JOIN line_item_status
        ON line_item_copy_status.line_item_status = line_item_status.line_item_status
      JOIN line_item_funds
        ON line_item_copy_status.copy_id = line_item_funds.copy_id
      JOIN fund reporting_fund
        ON line_item_funds.fund_id = reporting_fund.fund_id
        AND line_item_funds.ledger_id = reporting_fund.ledger_id
      JOIN fund allocated_fund
        ON reporting_fund.parent_fund = allocated_fund.fund_id
        AND reporting_fund.ledger_id = allocated_fund.ledger_id
      JOIN ledger
        ON line_item_funds.ledger_id = ledger.ledger_id
      JOIN po_type
        ON purchase_order.po_type = po_type.po_type
    WHERE line_item_copy_status.mfhd_id IN (#{mfhd_ids.names})
  )
end

def order_info_by_bibs(bib_ids)
  bib_ids = OCI8.in_cond(:bib_ids, bib_ids)
  %(
    SELECT
      line_item.bib_id,
      purchase_order.po_number,
      purchase_order.po_approve_date,
      purchase_order.po_id,
      po_status.po_status_desc,
      line_item.line_item_id,
      purchase_order.conversion_rate,
      line_item_status.line_item_status_desc,
      reporting_fund.fund_code,
      allocated_fund.fund_code,
      line_item_funds.amount,
      ledger.ledger_name
    FROM line_item
      JOIN purchase_order
        ON line_item.po_id = purchase_order.po_id
      JOIN po_status
        ON purchase_order.po_status = po_status.po_status
      JOIN line_item_copy_status
        ON line_item.line_item_id = line_item_copy_status.line_item_id
      JOIN line_item_status
        ON line_item_copy_status.line_item_status = line_item_status.line_item_status
      JOIN line_item_funds
        ON line_item_copy_status.copy_id = line_item_funds.copy_id
      JOIN fund reporting_fund
        ON line_item_funds.fund_id = reporting_fund.fund_id
        AND line_item_funds.ledger_id = reporting_fund.ledger_id
      JOIN fund allocated_fund
        ON reporting_fund.parent_fund = allocated_fund.fund_id
        AND reporting_fund.ledger_id = allocated_fund.ledger_id
      JOIN ledger
        ON line_item_funds.ledger_id = ledger.ledger_id
    WHERE line_item.bib_id IN (#{bib_ids.names})
  )
end

def payment_info_by_bibs_all_ledgers(bib_ids)
  bib_ids = OCI8.in_cond(:bib_ids, bib_ids)
  %(
    SELECT
      line_item.bib_id,
      invoice.invoice_id,
      vendor.vendor_code,
      invoice.invoice_number,
      invoice.voucher_number,
      invoice_status.invoice_status_desc,
      invoice.invoice_status_date,
      invoice.invoice_date,
      invoice.conversion_rate,
      reporting_fund.fund_code,
      allocated_fund.fund_code,
      invoice_line_item_funds.amount,
      invoice_line_item_funds.percentage,
      vendor_account.account_number,
      ledger.ledger_name,
      fiscal_period.fiscal_period_name
    FROM line_item
      JOIN invoice_line_item
        ON line_item.line_item_id = invoice_line_item.line_item_id
      JOIN invoice_line_item_funds
        ON invoice_line_item.inv_line_item_id = invoice_line_item_funds.inv_line_item_id
      JOIN invoice
        ON invoice_line_item.invoice_id = invoice.invoice_id
      JOIN invoice_status
        ON invoice.invoice_status = invoice_status.invoice_status
      JOIN vendor
        ON invoice.vendor_id = vendor.vendor_id
      JOIN invoice_line_item_funds
        ON invoice_line_item.inv_line_item_id = invoice_line_item_funds.inv_line_item_id
      JOIN fund reporting_fund
        ON invoice_line_item_funds.fund_id = reporting_fund.fund_id
        AND invoice_line_item_funds.ledger_id = reporting_fund.ledger_id
      JOIN fund allocated_fund
        ON reporting_fund.parent_fund = allocated_fund.fund_id
        AND reporting_fund.ledger_id = allocated_fund.ledger_id
      JOIN ledger
        ON invoice_line_item_funds.ledger_id = ledger.ledger_id
      JOIN fiscal_period
        ON ledger.fiscal_year_id = fiscal_period.fiscal_period_id
      LEFT JOIN vendor_account
        ON invoice.account_id = vendor_account.account_id
    WHERE
      line_item.bib_id IN (#{bib_ids.names})
    GROUP BY
    line_item.bib_id,
    invoice.invoice_id,
    vendor.vendor_code,
    invoice.invoice_number,
    invoice.voucher_number,
    invoice_status.invoice_status_desc,
    invoice.invoice_status_date,
    invoice.invoice_date,
    invoice.conversion_rate,
    reporting_fund.fund_code,
    allocated_fund.fund_code,
    invoice_line_item_funds.amount,
    invoice_line_item_funds.percentage,
    vendor_account.account_number,
    ledger.ledger_name,
    fiscal_period.fiscal_period_name
  )
end

def payment_info_by_bibs(bib_ids, ledger)
  bib_ids = OCI8.in_cond(:bib_ids, bib_ids)
  %(
    SELECT
      line_item.bib_id,
      invoice.invoice_id,
      vendor.vendor_code,
      invoice.invoice_number,
      invoice.voucher_number,
      invoice_status.invoice_status_desc,
      invoice.invoice_status_date,
      invoice.invoice_date,
      invoice.conversion_rate,
      reporting_fund.fund_code,
      allocated_fund.fund_code,
      invoice_line_item_funds.amount,
      invoice_line_item_funds.percentage,
      vendor_account.account_number,
      ledger.ledger_name
    FROM line_item
      JOIN invoice_line_item
        ON line_item.line_item_id = invoice_line_item.line_item_id
      JOIN invoice_line_item_funds
        ON invoice_line_item.inv_line_item_id = invoice_line_item_funds.inv_line_item_id
      JOIN invoice
        ON invoice_line_item.invoice_id = invoice.invoice_id
      JOIN invoice_status
        ON invoice.invoice_status = invoice_status.invoice_status
      JOIN vendor
        ON invoice.vendor_id = vendor.vendor_id
      JOIN invoice_line_item_funds
        ON invoice_line_item.inv_line_item_id = invoice_line_item_funds.inv_line_item_id
      JOIN fund reporting_fund
        ON invoice_line_item_funds.fund_id = reporting_fund.fund_id
        AND invoice_line_item_funds.ledger_id = reporting_fund.ledger_id
      JOIN fund allocated_fund
        ON reporting_fund.parent_fund = allocated_fund.fund_id
        AND reporting_fund.ledger_id = allocated_fund.ledger_id
      JOIN ledger
        ON invoice_line_item_funds.ledger_id = ledger.ledger_id
      LEFT JOIN vendor_account
        ON invoice.account_id = vendor_account.account_id
    WHERE
      line_item.bib_id IN (#{bib_ids.names})
      AND ledger.ledger_name = '#{ledger}'
    GROUP BY
    line_item.bib_id,
    invoice.invoice_id,
    vendor.vendor_code,
    invoice.invoice_number,
    invoice.voucher_number,
    invoice_status.invoice_status_desc,
    invoice.invoice_status_date,
    invoice.invoice_date,
    invoice.conversion_rate,
    reporting_fund.fund_code,
    allocated_fund.fund_code,
    invoice_line_item_funds.amount,
    invoice_line_item_funds.percentage,
    vendor_account.account_number,
    ledger.ledger_name
  )
end

def payment_info_by_mfhds(mfhd_ids, ledger)
  mfhd_ids = OCI8.in_cond(:mfhd_ids, mfhd_ids)
  %(
    SELECT
      line_item_copy_status.mfhd_id,
      invoice.invoice_id,
      vendor.vendor_code,
      invoice.invoice_number,
      invoice.voucher_number,
      invoice_status.invoice_status_desc,
      invoice.invoice_status_date,
      invoice.invoice_date,
      invoice.conversion_rate,
      reporting_fund.fund_code,
      allocated_fund.fund_code,
      invoice_line_item_funds.amount,
      invoice_line_item_funds.percentage,
      vendor_account.account_number,
      ledger.ledger_name
    FROM line_item_copy_status
      JOIN invoice_line_item
        ON line_item_copy_status.line_item_id = invoice_line_item.line_item_id
      JOIN invoice_line_item_funds
        ON invoice_line_item.inv_line_item_id = invoice_line_item_funds.inv_line_item_id
      JOIN invoice
        ON invoice_line_item.invoice_id = invoice.invoice_id
      JOIN invoice_status
        ON invoice.invoice_status = invoice_status.invoice_status
      JOIN vendor
        ON invoice.vendor_id = vendor.vendor_id
      JOIN invoice_line_item_funds
        ON invoice_line_item.inv_line_item_id = invoice_line_item_funds.inv_line_item_id
      JOIN fund reporting_fund
        ON invoice_line_item_funds.fund_id = reporting_fund.fund_id
        AND invoice_line_item_funds.ledger_id = reporting_fund.ledger_id
      JOIN fund allocated_fund
        ON reporting_fund.parent_fund = allocated_fund.fund_id
        AND reporting_fund.ledger_id = allocated_fund.ledger_id
      JOIN ledger
        ON invoice_line_item_funds.ledger_id = ledger.ledger_id
      LEFT JOIN vendor_account
        ON invoice.account_id = vendor_account.account_id
    WHERE
      line_item_copy_status.mfhd_id IN (#{mfhd_ids.names})
      AND ledger.ledger_name = '#{ledger}'
    GROUP BY
    line_item_copy_status.mfhd_id,
    invoice.invoice_id,
    vendor.vendor_code,
    invoice.invoice_number,
    invoice.voucher_number,
    invoice_status.invoice_status_desc,
    invoice.invoice_status_date,
    invoice.invoice_date,
    invoice.conversion_rate,
    reporting_fund.fund_code,
    allocated_fund.fund_code,
    invoice_line_item_funds.amount,
    invoice_line_item_funds.percentage,
    vendor_account.account_number,
    ledger.ledger_name
  )
end
