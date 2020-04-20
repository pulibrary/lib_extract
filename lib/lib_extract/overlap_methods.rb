### Pass in bib IDs and the directory where the full dump is
### source identifiers relate to bibids passed in; other identifiers are for other bibs

def overlap_analysis_for_bibs(bib_ids:, path:)
  # Get overlap info for source bib IDs and all others
  source_overlap_info = {}
  other_overlap_info = {}
  Dir.glob("#{path}/*.mrc").each do |file|
    reader = MARC::Reader.new(file)
    reader.each do |record|
      id = record['001'].value.to_i
      overlap_info = get_overlap_info_from_record(record)
      overlap_info.delete(:id)
      oclc_910b = []
      record.fields('910').each do |field|
        vals = get_oclc_from_field(field, 'b')
        oclc_910b += vals
      end
      overlap_info[:std_nos][:oclc] += oclc_910b
      if bib_ids.include?(id)
        source_overlap_info[id] = overlap_info
      else
        other_overlap_info[id] = overlap_info
      end
    end
  end

  # Get overlap of identifiers
  source_lccn = source_overlap_info.values.map { |info| info[:std_nos][:lccn] }
  source_lccn.flatten!
  source_lccn.uniq!
  other_lccn = other_overlap_info.values.map { |info| info[:std_nos][:lccn] }
  other_lccn.flatten!
  other_lccn.uniq!
  overlap_lccn = source_lccn & other_lccn

  source_isbn = source_overlap_info.values.map { |info| info[:std_nos][:isbn] }
  source_isbn.flatten!
  source_isbn.uniq!
  other_isbn = other_overlap_info.values.map { |info| info[:std_nos][:isbn] }
  other_isbn.flatten!
  other_isbn.uniq!
  overlap_isbn = source_isbn & other_isbn

  source_issn = source_overlap_info.values.map { |info| info[:std_nos][:issn] }
  source_issn.flatten!
  source_issn.uniq!
  other_issn = other_overlap_info.values.map { |info| info[:std_nos][:issn] }
  other_issn.flatten!
  other_issn.uniq!
  overlap_issn = source_issn & other_issn

  source_oclc = source_overlap_info.values.map { |info| info[:std_nos][:oclc] }
  source_oclc.flatten!
  source_oclc.uniq!
  other_oclc = other_overlap_info.values.map { |info| info[:std_nos][:oclc] }
  other_oclc.flatten!
  other_oclc.uniq!
  overlap_oclc = source_oclc & other_oclc

  source_title = source_overlap_info.values.map { |info| info[:title_brief] }
  source_title.uniq!
  other_title = other_overlap_info.values.map { |info| info[:title_brief] }
  other_title.uniq!
  overlap_title = source_title & other_title

  # Get source records where two identifiers match
  #   the overlapping standard numbers
  source_lccn_isbn_overlap = source_overlap_info.select do |_id, info|
    info[:std_nos][:lccn] &&
      !(info[:std_nos][:lccn] & overlap_lccn).empty? &&
      info[:std_nos][:isbn] &&
      !(info[:std_nos][:isbn] & overlap_isbn).empty?
  end

  source_lccn_issn_overlap = source_overlap_info.select do |_id, info|
    info[:std_nos][:lccn] &&
      !(info[:std_nos][:lccn] & overlap_lccn).empty? &&
      info[:std_nos][:issn] &&
      !(info[:std_nos][:issn] & overlap_issn).empty?
  end

  source_lccn_oclc_overlap = source_overlap_info.select do |_id, info|
    info[:std_nos][:lccn] &&
      !(info[:std_nos][:lccn] & overlap_lccn).empty? &&
      info[:std_nos][:oclc] &&
      !(info[:std_nos][:oclc] & overlap_oclc).empty?
  end

  source_lccn_title_overlap = source_overlap_info.select do |_id, info|
    info[:std_nos][:lccn] &&
      !(info[:std_nos][:lccn] & overlap_lccn).empty? &&
      overlap_title.include?(info[:title_brief])
  end

  source_isbn_issn_overlap = source_overlap_info.select do |_id, info|
    info[:std_nos][:isbn] &&
      !(info[:std_nos][:isbn] & overlap_isbn).empty? &&
      info[:std_nos][:issn] &&
      !(info[:std_nos][:issn] & overlap_issn).empty?
  end

  source_isbn_oclc_overlap = source_overlap_info.select do |_id, info|
    info[:std_nos][:isbn] &&
      !(info[:std_nos][:isbn] & overlap_isbn).empty? &&
      info[:std_nos][:oclc] &&
      !(info[:std_nos][:oclc] & overlap_oclc).empty?
  end

  source_isbn_title_overlap = source_overlap_info.select do |_id, info|
    info[:std_nos][:isbn] &&
      !(info[:std_nos][:isbn] & overlap_isbn).empty? &&
      overlap_title.include?(info[:title_brief])
  end

  source_issn_oclc_overlap = source_overlap_info.select do |_id, info|
    info[:std_nos][:issn] &&
      !(info[:std_nos][:issn] & overlap_issn).empty? &&
      info[:std_nos][:oclc] &&
      !(info[:std_nos][:oclc] & overlap_oclc).empty?
  end

  source_issn_title_overlap = source_overlap_info.select do |_id, info|
    info[:std_nos][:issn] &&
      !(info[:std_nos][:issn] & overlap_issn).empty? &&
      overlap_title.include?(info[:title_brief])
  end

  source_oclc_title_overlap = source_overlap_info.select do |_id, info|
    info[:std_nos][:oclc] &&
      !(info[:std_nos][:oclc] & overlap_oclc).empty? &&
      overlap_title.include?(info[:norm_title])
  end

  # Create a hash with source bib IDs as the keys and
  #   matching other bibs as the values
  source_to_other = {}
  source_lccn_isbn_overlap.each do |id, info|
    matches = other_overlap_info.select do |_match_id, match_info|
      !(match_info[:std_nos][:lccn] & info[:std_nos][:lccn]).empty? &&
        !(match_info[:std_nos][:isbn] & info[:std_nos][:isbn]).empty?
    end
    unless matches.empty?
      source_to_other[id] ||= []
      matches.each_key { |match_id| source_to_other[id] << match_id }
    end
  end

  source_lccn_issn_overlap.each do |id, info|
    matches = other_overlap_info.select do |_match_id, match_info|
      !(match_info[:std_nos][:lccn] & info[:std_nos][:lccn]).empty? &&
        !(match_info[:std_nos][:issn] & info[:std_nos][:issn]).empty?
    end
    unless matches.empty?
      source_to_other[id] ||= []
      matches.each_key { |match_id| source_to_other[id] << match_id }
    end
  end

  source_lccn_oclc_overlap.each do |id, info|
    matches = other_overlap_info.select do |_match_id, match_info|
      !(match_info[:std_nos][:lccn] & info[:std_nos][:lccn]).empty? &&
        !(match_info[:std_nos][:oclc] & info[:std_nos][:oclc]).empty?
    end
    unless matches.empty?
      source_to_other[id] ||= []
      matches.each_key { |match_id| source_to_other[id] << match_id }
    end
  end

  source_lccn_title_overlap.each do |id, info|
    matches = other_overlap_info.select do |_match_id, match_info|
      !(match_info[:std_nos][:lccn] & info[:std_nos][:lccn]).empty? &&
        match_info[:title_brief] == info[:title_brief]
    end
    unless matches.empty?
      source_to_other[id] ||= []
      matches.each_key { |match_id| source_to_other[id] << match_id }
    end
  end

  source_isbn_issn_overlap.each do |id, info|
    matches = other_overlap_info.select do |_match_id, match_info|
      !(match_info[:std_nos][:isbn] & info[:std_nos][:isbn]).empty? &&
        !(match_info[:std_nos][:issn] & info[:std_nos][:issn]).empty?
    end
    unless matches.empty?
      source_to_other[id] ||= []
      matches.each_key { |match_id| source_to_other[id] << match_id }
    end
  end

  source_isbn_oclc_overlap.each do |id, info|
    matches = other_overlap_info.select do |_match_id, match_info|
      !(match_info[:std_nos][:isbn] & info[:std_nos][:isbn]).empty? &&
        !(match_info[:std_nos][:oclc] & info[:std_nos][:oclc]).empty?
    end
    unless matches.empty?
      source_to_other[id] ||= []
      matches.each_key { |match_id| source_to_other[id] << match_id }
    end
  end

  source_isbn_title_overlap.each do |id, info|
    matches = other_overlap_info.select do |_match_id, match_info|
      !(match_info[:std_nos][:isbn] & info[:std_nos][:isbn]).empty? &&
        match_info[:title_brief] == info[:title_brief]
    end
    unless matches.empty?
      source_to_other[id] ||= []
      matches.each_key { |match_id| source_to_other[id] << match_id }
    end
  end

  source_issn_oclc_overlap.each do |id, info|
    matches = other_overlap_info.select do |_match_id, match_info|
      !(match_info[:std_nos][:issn] & info[:std_nos][:issn]).empty? &&
        !(match_info[:std_nos][:oclc] & info[:std_nos][:oclc]).empty?
    end
    unless matches.empty?
      source_to_other[id] ||= []
      matches.each_key { |match_id| source_to_other[id] << match_id }
    end
  end

  source_issn_title_overlap.each do |id, info|
    matches = other_overlap_info.select do |_match_id, match_info|
      !(match_info[:std_nos][:issn] & info[:std_nos][:issn]).empty? &&
        match_info[:title_brief] == info[:title_brief]
    end
    unless matches.empty?
      source_to_other[id] ||= []
      matches.each_key { |match_id| source_to_other[id] << match_id }
    end
  end

  source_oclc_title_overlap.each do |id, info|
    matches = other_overlap_info.select do |_match_id, match_info|
      !(match_info[:std_nos][:oclc] & info[:std_nos][:oclc]).empty? &&
        match_info[:title_brief] == info[:title_brief]
    end
    unless matches.empty?
      source_to_other[id] ||= []
      matches.each_key { |match_id| source_to_other[id] << match_id }
    end
  end

  ### Clean up the matches
  source_to_other.each_value(&:uniq!)
  source_to_other
end
