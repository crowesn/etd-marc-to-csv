# map etd marc records to csv for scholar batch load

require 'marc'
require 'csv'
require 'rails'

def fields 
  Hash[headers.map(&:to_sym).zip]
end

def headers 
  %w(work_type submitter_email title type creator advisors college department
     degree alt_description publisher date_created subject language genre note 
     visibility rights doi member_of_collection_ids file_path file_title 
     file_visibility file_embargo_release_date file_uri file_pid)
end

def what
  raise "what's this value supposed to be?"
end

# open marc input file
reader = MARC::Reader.new('MARCDATA.MRC')

# instantiate csv output file
csv = CSV.open( what, "wb" )

# add headers
csv << headers

# create metadata skeleton hash and populate vals with each marc record

reader.each do |record|

  metadata = fields

  # build record
  metadata[:work_type] = "Etd"
  metadata[:submitter_email] = what
  metadata[:title] = record['245']['a'].titleize
  metadata[:type] = what # RDF objects?
  metadata[:creator] = record['100']['a']
  metadata[:college] = "Other"
  metadata[:department] = "Other"
  metadata[:degree] = record['791']['a']
  metadata[:alt_description] = record['500']['a']
  metadata[:publisher] = record['710']['a']
  metadata[:date_created] = record['792']['a']
  metadata[:subject] = record['650']['a']
  metadata[:language] = record['793']['a']
  metadata[:visibility] = 'open'
  metadata[:rights] = what # license URI
  metadata[:file_title] = record['001'].tr('AAI')
  metadata[:file_visibility] = 'open'
  metadata[:file_uri] = record['001'].tr('AAI')
  metadata[:file_pid] = what
  # add row to csv

  csv << metadata.values
end

