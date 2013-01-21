require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'redis'

redis = Redis.new(:host => '198.61.212.105', :port => 6379)

# get the data from glance and load into redis (if name doesn't match)
# update the data in redis if name matches and data doesn't match
doc = Nokogiri::HTML(open('https://blueprints.launchpad.net/glance'))
doc.css('table#speclisting > tbody > tr').each do |row|
 puts "priority"
 if row.elements[0].elements.count > 1 then
   puts row.elements[0].elements[1].content
 elsif row.elements[0].elements.count > 0 then
   puts row.elements[0].elements[0].content
 end
 puts 'blueprint ==> '
 if row.elements[1].elements.count > 1 then
   puts row.elements[1].elements[1].content
 elsif row.elements[1].elements.count > 0 then
   puts row.elements[1].elements[0].content
 end
 puts 'design ==> '
 if row.elements[2].elements.count > 1 then
   puts row.elements[2].elements[1].content
 elsif row.elements[2].elements.count > 0 then
   puts row.elements[2].elements[0].content
 end
  puts 'delivery ==> '
 if row.elements[3].elements.count > 1 then
   puts row.elements[3].elements[1].content
 elsif row.elements[3].elements.count > 0 then
   puts row.elements[3].elements[0].content
 end
 puts 'assignee ==> '
 if row.elements[4].elements.count > 1 then
   puts row.elements[4].elements[1].content
 elsif row.elements[4].elements.count > 0 then
   puts row.elements[4].elements[0].content
 end
 puts 'series ==> '
 if row.elements[0].elements.count > 1 then
   puts row.elements[0].elements[1].content
 elsif row.elements[0].elements.count > 0 then
   puts row.elements[0].elements[0].content
 end
end
