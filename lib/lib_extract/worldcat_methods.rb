def worldcat_conn
  conn = Faraday.new(url: WORLDCAT_SEARCH_URL) do |faraday|
    faraday.request   :url_encoded
    faraday.response  :logger
    faraday.adapter   Faraday.default_adapter
  end
  conn
end

### Maximum of 100 OCLC nums allowed in query
def get_worldcat_recs_by_query(query, num_records = 1)
  response = worldcat_conn.get do |req|
    req.params['query'] = query
    req.params['maximumRecords'] = num_records.to_s
    req.params['servicelevel'] = 'full'
    req.params['sortKeys'] = 'LibraryCount,,0'
    req.params['wskey'] = WORLDCAT_API_KEY
    req.params['frbrGrouping'] = 'off'
  end
  return nil unless response.body =~ /<recordData>/
  records_from_record_body(response.body)
end

### Search API result parsing
def records_from_record_body(body)
  records = []
  doc = Nokogiri::XML(body)
  doc.xpath('//xmlns:records/xmlns:record/xmlns:recordData/*').wrap('<collection></collection>')
  doc.xpath('//xmlns:records/xmlns:record/xmlns:recordData/xmlns:collection').each do |node|
    reader = MARC::XMLReader.new(StringIO.new(node.to_xml))
    records << reader.first
  end
  records_to_id_hash(records)
end

def records_to_id_hash(records)
  hash = {}
  records.each do |record|
    id = record['001'].value.gsub(/[^0-9]/, '')
    hash[id.to_i] = record
  end
  hash
end
