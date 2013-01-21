require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'redis'
require 'json'

redis = Redis.new(:host => '198.61.212.105', :port => 6379)
redis.del "blueprints"
# get the data from glance and load into redis (if name doesn't match)
# update the data in redis if name matches and data doesn't match
doc = Nokogiri::HTML(open('https://blueprints.launchpad.net/glance'))
doc.css('table#speclisting > tbody > tr').each do |row|
 blueprint = Hash.new
 # "priority"
 if row.elements[0].elements.count > 1 then
   blueprint['priority'] = row.elements[0].elements[1].content
 elsif row.elements[0].elements.count > 0 then
   blueprint['priority'] = row.elements[0].elements[0].content
 end
 #'blueprint ==> '
 if row.elements[1].elements.count > 1 then
   blueprint['name'] = row.elements[1].elements[1].content
 elsif row.elements[1].elements.count > 0 then
   blueprint['name'] = row.elements[1].elements[0].content
 end
 # 'design ==> '
 if row.elements[2].elements.count > 1 then
   blueprint['design'] = row.elements[2].elements[1].content
 elsif row.elements[2].elements.count > 0 then
   blueprint['design'] = row.elements[2].elements[0].content
 end
 #'delivery ==> '
 if row.elements[3].elements.count > 1 then
   blueprint['delivery'] = row.elements[3].elements[1].content
 elsif row.elements[3].elements.count > 0 then
   blueprint['delivery'] = row.elements[3].elements[0].content
 end
 # 'assignee ==> '
 if row.elements[4].elements.count > 1 then
   blueprint['assignee'] = row.elements[4].elements[1].content
 elsif row.elements[4].elements.count > 0 then
   blueprint['assignee'] = row.elements[4].elements[0].content
 end
 # 'series ==> '
 if row.elements[0].elements.count > 1 then
   blueprint['series'] = row.elements[0].elements[1].content
 elsif row.elements[0].elements.count > 0 then
   blueprint['series'] = row.elements[0].elements[0].content
 end
 
 blueprint_name = blueprint['name']
 redis.del "blueprint___" + blueprint_name
 redis.set "blueprint___" + blueprint_name, blueprint.to_json
 redis.rpush 'blueprints', blueprint_name
end
