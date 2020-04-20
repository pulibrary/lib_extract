### Limited to 100 ISBNs at a time; however, usually it is better to
###   query one at a time, since one ISBN can return multiple records
def bulk_isbn_query(isbns)
  string = "srw.bn any \"#{isbns.first}\""
  isbns[1..-1].each do |num|
    string << " or srw.bn any \"#{num}\""
  end
  string
end

### Limited to 100 ISSNs at a time; however, usually it is better to
###   query one at a time, since one ISSN can return multiple records
def bulk_issn_query(issns)
  string = "srw.in any \"#{issns.first}\""
  issns[1..-1].each do |num|
    string << " or srw.in any \"#{num}\""
  end
  string
end

### Limited to 100 OCLC numbers at a time
def bulk_oclc_query(oclc_nos)
  string = "srw.no any \"#{oclc_nos.first}\""
  oclc_nos[1..-1].each do |num|
    string << " or srw.no any \"#{num}\""
  end
  string
end

### Searches one LCCN at a time, requiring the record to be a PCC record
def lccn_query(lccn)
  "srw.dn any \"#{lccn}\" and srw.pc any \"Y\""
end
