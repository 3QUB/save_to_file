require "google_drive"
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pry'

#session.upload_from_file("/Users/quentinberson/THP/Google_Drive/hello.txt", "hello.txt", convert: false)

#Il faut laisser tourner le script 1 minute. J'affiche tout d'un coup!

def mairie (lien_mairie)
  mairie_page = Nokogiri::HTML(open(lien_mairie))
  mairie_h1 = mairie_page.css("div[1]/main/section[1]/div/div/div/h1").text.split(" - ") #On cherche le H1 et on split pour séparer le nom et le Zip Code
  mairie_name = mairie_h1[0]
  mairie_postal_code = mairie_h1[1]
  mairie_email = mairie_page.css("div[1]/main/section[2]/div/table/tbody/tr[4]/td[2]").text
  #h = Hash[:name => mairie_name,:zip_code => mairie_postal_code, :email => mairie_email, :source => lien_mairie]
  h = Hash[:name => mairie_name, :email => mairie_email]
  return h
end

def send_to_spreadsheet (hash_array)
  session = GoogleDrive::Session.from_config("config.json")
  ws = session.spreadsheet_by_key("PUT YOUR KEY HERE").worksheets[0]
  ws[1, 1] = "Mairie"
  ws[1, 2] = "Email"
  i = 2
  hash_array.each{ |x|
  ws[i, 1] = x[:name]
  ws[i, 2] = x[:email]
  ws.save
  i += 1
  }
end

def scan_list_mairie (lien)
  url_origin = "http://annuaire-des-mairies.com/"
  list_mairie = []
  page_origin = Nokogiri::HTML(open(lien))
  mairie_link = page_origin.css('a.lientxt')
  mairie_link.each {|x|
    link = x['href']
    link_to_mairie = URI.join(url_origin, link).to_s
    list_mairie.push(mairie(link_to_mairie))
}
#puts list_mairie
return list_mairie
end

def perform
  url_origin = "http://annuaire-des-mairies.com/val-d-oise.html"
  send_to_spreadsheet(scan_list_mairie(url_origin))
end

perform