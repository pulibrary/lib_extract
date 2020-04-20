### Rows are
###   TransactionNumber
###   RequestType
###   Username
###   CreationDate
###   TransactionStatus
###   TransactionDate
###   ProcessType
###   LendingLibrary
###   ISSN (ISSN and ISBN)
###   ESPNumber (OCLC number, if SystemID = 'OCLC')
###   ILLNumber
###   SystemID
def get_illiad_borrowing(client)
  results = []
  request = client.execute(illiad_all_borrowing)
  request.each do |row|
    results << row
  end
end

### Rows are
###   TransactionNumber
###   RequestType
###   Username
###   CreationDate
###   TransactionStatus
###   TransactionDate
###   ProcessType
###   LendingLibrary
###   ISSN (ISSN and ISBN)
###   ESPNumber (OCLC number, if SystemID = 'OCLC')
###   ILLNumber
###   SystemID
def get_illiad_lending(client)
  results = []
  request = client.execute(illiad_all_lending)
  request.each do |row|
    results << row
  end
end

### Returns a hash with OCLC, ISBN, and ISSN
def std_nums_from_illiad(requests)
  oclcs = oclc_nums_from_illiad(requests)
  isxn = isbn_issn_from_illiad(requests)
  results = {}
  oclcs.each do |trans_num, oclc|
    results[trans_num] ||= {}
    results[trans_num][:oclc] = oclc
  end
  isxn.each do |trans_num, vals|
    results[trans_num] ||= {}
    results[trans_num][:isbn] = vals[:isbn]
    results[trans_num][:issn] = vals[:issn]
  end
  results
end

### Assumes output from the get methods defined in this document
def oclc_nums_from_illiad(requests)
  results = {}
  requests.each do |request|
    oclc = request['SystemID'] == 'OCLC' ? request['ESPNumber'] : nil
    oclc = oclc_normalize(oclc, false) if oclc
    if oclc
      oclc.gsub!(/[^0-9]/, '')
      oclc.gsub!(/^0+([1-9][0-9]+)$/, '\1')
    end
    results[request['TransactionNumber']] = oclc
  end
  results
end

### Assumes output from the get methods defined in this document
###   Returns a hash with transaction numbers as the key
def isbn_issn_from_illiad(requests)
  results = {}
  requests.each do |request|
    next unless request['ISSN']
    isbn = isbn_normalize(request['ISSN'])
    issn = issn_normalize(request['ISSN'])
    results[request['TransactionNumber']] = { isbn: isbn, issn: issn }
  end
  results
end
