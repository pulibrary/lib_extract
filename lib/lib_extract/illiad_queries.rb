def illiad_all_borrowing
  %(
    SELECT
      TransactionNumber,
      RequestType,
      Username,
      CreationDate,
      TransactionStatus,
      TransactionDate,
      ProcessType,
      LendingLibrary,
      ISSN,
      ESPNumber,
      ILLNumber,
      SystemID
  FROM Transactions
  WHERE
      TransactionStatus != 'Cancelled by ILL Staff'
      AND RequestType = 'Loan'
      AND ProcessType = 'Borrowing'
  ORDER BY TransactionNumber
  )
end

def illiad_all_lending
  %(
    SELECT
      TransactionNumber,
      RequestType,
      Username,
      CreationDate,
      TransactionStatus,
      TransactionDate,
      ProcessType,
      LendingLibrary,
      ISSN,
      ESPNumber,
      ILLNumber,
      SystemID
  FROM Transactions
  WHERE
      TransactionStatus != 'Cancelled by ILL Staff'
      AND RequestType = 'Loan'
      AND ProcessType = 'Lending'
  ORDER BY TransactionNumber
  )
end
