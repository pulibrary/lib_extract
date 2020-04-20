require 'oci8'
require 'set'
require 'marc'
require 'library_stdnums'
require 'tiny_tds'
require 'faraday'
require 'nokogiri'
require 'marc_cleanup'

ROOT_DIR = File.join(File.dirname(__FILE__), '..')
Dir.glob("#{ROOT_DIR}/lib/ils_sql/*.rb").each do |file|
  require file
end
