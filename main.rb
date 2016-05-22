require 'nokogiri'
require 'open-uri'
require 'rubygems'
require 'pdf/reader'

landen = {'be/nl' =>0.0, 'fr/fr'=>0.0, 'nl/nl'=>0.0}

def parse_prijs(variable)
  variable.strip!.tr('^0-9,.', '').to_f.to_s
end

def get_local_ikea(landcode, productid)
  @doc = Nokogiri::HTML(open('http://www.ikea.com/'+landcode+'/catalog/products/'+productid+"/"))
  prijs = parse_prijs(@doc.css('#price1').first.content)
  puts landcode+"\t" + prijs
  prijs
end

def get_product_codes
  filename = File.expand_path(File.dirname(__FILE__)) + "/20151223 - keuken.pdf"
  nummers =[]
  PDF::Reader.open(filename) do |reader|
    reader.pages.each do |page|
      nummers += page.text.scan(/\d\d\d\.?\d\d\d\.?\d\d/)
    end
  end
  nummers.uniq
end

get_product_codes.sort.each do |product|
  puts '-----------------'
  p = product.tr('^0-9', '')
  puts p
  begin
    @doc = Nokogiri::HTML(open('http://www.ikea.com/be/nl/catalog/products/'+p+'/'))
    naam = product + "\t" + @doc.css('#name').first.content.strip! + ' - ' + @doc.css('#type').first.content.strip!
    puts naam
    #puts 'Aantal?'
    #aantal = STDIN.gets.chomp
    landen.each do |(land)|
      prijs = get_local_ikea(land,p);
      landen[land]=landen[land]+(prijs.to_f)
    end
  rescue OpenURI::HTTPError => e
    if e.message == '404 Not Found'
      puts 'geen productinfo'
    else
      raise e
    end
  rescue nil::NoMethodError => e
    puts 'geen product, redirect'
  end
end



puts '- - - - - - - - - -'
puts 'TOTAAL:'
landen.each do |(land,totaal)|
  puts land + "\t" +totaal.round(2).to_s
end
