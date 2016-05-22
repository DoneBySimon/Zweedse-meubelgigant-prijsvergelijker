require 'rubygems'
require 'pdf/reader'

filename = File.expand_path(File.dirname(__FILE__)) + "/list2.pdf"

PDF::Reader.open(filename) do |reader|
  reader.pages.each do |page|
    puts page.text
    #nummers = page.text.scan(/\d\d\d\.\d\d\d\.\d\d/)
    # nummers.uniq.each do |nummer|
    #  puts nummer
    # end
  end
end