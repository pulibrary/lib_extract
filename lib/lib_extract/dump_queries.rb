def bulk_bib(bib_ids)
  bib_ids = OCI8.in_cond(:bib_ids, bib_ids)
  %(
  SELECT record_segment
  FROM bib_data
  WHERE bib_id IN (#{bib_ids.names})
  ORDER BY bib_id, seqnum
  )
end

def mfhds_for_bibs(bib_ids)
  bib_ids = OCI8.in_cond(:bib_ids, bib_ids)
  %(
    SELECT
     bib_mfhd.bib_id,
     record_segment
     FROM mfhd_data
      JOIN bib_mfhd
        ON mfhd_data.mfhd_id = bib_mfhd.mfhd_id
      JOIN mfhd_master
        ON bib_mfhd.mfhd_id = mfhd_master.mfhd_id
    WHERE
     bib_id IN (#{bib_ids.names})
     AND mfhd_master.suppress_in_opac = 'N'
     ORDER BY bib_mfhd.mfhd_id, seqnum
  )
end

def all_auth_ids
  %(
    SELECT auth_id
    FROM auth_master
  )
end

def bulk_auth(auth_ids)
  auth_ids = OCI8.in_cond(:auth_ids, auth_ids)
  %(
  SELECT record_segment
  FROM auth_data
  WHERE auth_id IN (#{auth_ids.names})
  ORDER BY auth_id, seqnum
  )
end
