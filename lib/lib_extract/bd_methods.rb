require 'time'

def parse_bd_row(row)
  req_num = row['REQUEST NUMBER']
  oclc_val = oclc_normalize(row['OCLC'], false)
  if oclc_val
    oclc_val.gsub!(/[^0-9]/, '')
    oclc_val = oclc_val.to_i
    oclc_val = oclc_val.to_s
  end
  info = {
    lender: row['LENDER'],
    borrower: row['BORROWER'],
    pick_up: row['PICK UP LOCATION'],
    req_date: row['REQUEST DATE'] == '' ? nil : Time.parse(row['REQUEST DATE']),
    ship_date: row['SHIP DATE'] == '' ? nil : Time.parse(row['SHIP DATE']),
    rec_date: row['RECEIVED DATE'] == '' ? nil : Time.parse(row['RECEIVED DATE']),
    status: row['STATUS'],
    shelving_loc: row['SHELVING LOCATION'],
    patron_type: row['PATRON TYPE'],
    author: row['AUTHOR'],
    title: row['TITLE'],
    publisher: row['PUBLISHER'],
    pub_place: row['PUBLICATION PLACE'],
    pub_year: row['PUBLICATION YEAR'],
    isbn: isbn_normalize(row['ISBN']),
    oclc: oclc_val,
    lccn: StdNum::LCCN.normalize(row['LCCN']),
    call_num: row['CALL NUMBER'],
    item_found: row['LOCAL_ITEM_FOUND']
  }
  { req_num: req_num, info: info }
end
