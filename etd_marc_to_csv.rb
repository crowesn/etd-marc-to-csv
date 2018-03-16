# Script to map etd marc records to csv for scholar batch load

##############
#
# Configuration
#
marc_file = what # replace `what` with your marc file name/path
#
output_file = what # replace `what` with your output file name/path
#
#
##############

['marc', 'csv', 'rails'].each do |requirement|
  require requirement
end

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
  raise "Config error: What's this value supposed to be?"
end

def advisors(record)
  # get records
  a = []
  record.fields('500').reject{|item| item.value.match /^Source.*/}.each do |r|
    a << r.value
  end
  a.join('|') 
end

def subjects(record)
  a = []
  record.fields('650'){|x| x.value}.each do |r|
    a << r.value
  end
  a.join('|')
end

# open marc input file
reader = MARC::Reader.new(marc_file)

# instantiate csv output file
csv = CSV.open( output_file, "wb" )

# add headers
csv << headers

# create metadata skeleton hash and populate vals with each marc record

reader.each do |record|

  metadata = fields

  # build record
  metadata[:work_type] = "Etd"
  metadata[:submitter_email] = what # I think we still need an account to own these, should prob not be the grad school
  metadata[:title] = record['245']['a'].titleize
  metadata[:creator] = record['100']['a'].titleize
  metadata[:college] = "Other"
  metadata[:department] = "Other"
  metadata[:alt_description] = record['520'].value unless record['520'].nil?
  metadata[:publisher] = record['710']['a']
  metadata[:degree] = record['791']['a']
  metadata[:advisors] = advisors(record)
  metadata[:date_created] = record['792']['a']
  metadata[:subject] = subjects(record)
  metadata[:language] = record['793']['a']
  metadata[:visibility] = 'open'
  metadata[:rights] = 'http://rightsstatements.org/vocab/InC/1.0/'
  metadata[:doi] = 'FALSE'
  metadata[:file_visibility] = 'open'
  metadata[:file_path] = record['001'].value.tr('AAI', '') + '.pdf'

  # add row to csv
  csv << metadata.values
end

