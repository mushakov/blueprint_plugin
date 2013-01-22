require 'rubygems'
require 'sinatra'
require 'json'
require 'redis'
require 'uri'
require '/home/dimtruck/pet-projects/glance/main.rb'
redis = Redis.new(:host => '198.61.212.105', :port => 6379)
 
get '/' do
  status 200
  html = "<html><head><title>Glance Rackspace</title><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><body>" 
  html += "<button data-bind='click: refresh_data'>Refresh Data</button><br/>"
  html += "<table><thead><tr><th>Blueprint</th><th>Priority</th><th>Delivery</th><th>Series</th><th>Assignee</th><th>Design</th><th>Is Racker</th><th>Comments</th><th>Actions</th></tr></thead><tbody data-bind='foreach: blueprints'>"
  html += "<tr><td data-bind='text: name'></td>"
  html += "<td data-bind='text: priority'></td>"
  html += "<td data-bind='text: delivery'></td>"
  html += "<td data-bind='text: series'></td>"
  html += "<td data-bind='text: assignee'></td>"
  html += "<td data-bind='text: design'></td>"
  html += "<td><span data-bind='text: isracker,visible: showRacker'></span><input data-bind='value: isracker,visible: showRackerInput'/></td>"
  html += "<td><span data-bind='text: comments,visible: showComments'></span><input data-bind='value: comments,visible: showCommentsInput'/></td>"
  html += "<td><button data-bind='click: $parent.update, visible: showUpdateButton'>Update</button><button data-bind='click: $parent.save,visible: showSaveButton'>Save</button><button data-bind='click: $parent.cancel, visible: showCancelButton'>Cancel</button></td></tr>"
  html += "</tbody></table></body>"
  html += "<script src=\"http://code.jquery.com/jquery-1.8.2.min.js\"></script><script type=\"text/javascript\" src=\"http://ajax.aspnetcdn.com/ajax/knockout/knockout-2.2.1.js\"></script>"
  html += "<script type=\"text/javascript\">"
  html += "function Blueprint(item){"
  html += "this.name = item.name; " 
  html += "this.priority = item.priority; "
  html += "this.delivery = item.delivery; "
  html += "this.series = item.series; "
  html += "this.assignee = item.assignee; "
  html += "this.design = item.design; "
  html += "this.isracker = ko.observable(item.isracker); "
  html += "this.comments = ko.observable(item.comments); "
  html += "this.showUpdateButton = ko.observable(true);"
  html += "this.showSaveButton = ko.observable(false);"
  html += "this.showCancelButton = ko.observable(false);"
  html += "this.showRacker = ko.observable(true);"
  html += "this.showRackerInput = ko.observable(false);"
  html += "this.showComments = ko.observable(true);"
  html += "this.showCommentsInput = ko.observable(false);"
  html += "} "
  html += "function BluePrintViewModel(){"
  html += "var self = this;"
  html += "self.blueprints = ko.observableArray([]);"
  html += "$.getJSON('/load_blueprints', function(allData){"
  html += "var mappedBlueprints = $.map(allData, function(item){ return new Blueprint(item); });"
  html += "console.log(mappedBlueprints); "
  html += "self.blueprints(mappedBlueprints);});"
  html += "self.refresh_data = function(){"
  html += "$.getJSON('/refresh_data',function(allData){"
  html += "var mappedBlueprints = $.map(allData, function(item){ return new Blueprint(item); });"
  html += "console.log(mappedBlueprints); "
  html += "self.blueprints(mappedBlueprints);});"
  html += "alert('updated');};"
  html += "self.update = function(item){item.showRackerInput(true); item.showRacker(false); item.showComments(false); item.showCommentsInput(true); item.showUpdateButton(false); item.showSaveButton(true); item.showCancelButton(true);};"
  html += "self.save = function(item){item.showCommentsInput(false); item.showRackerInput(false); item.showComments(true); item.showRacker(true); item.showUpdateButton(true); item.showSaveButton(false); item.showCancelButton(false);"
  html += "console.log(ko.toJSON({item: item}));"
  html += "$.ajax('/update_blueprint', {data: ko.toJSON({item:item}), type:'post',contentType:'application/json',success:function(data){}})};"
  html += "self.cancel = function(item){item.showCommentsInput(false); item.showRackerInput(false); item.showComments(true); item.showRacker(true); item.showUpdateButton(true); item.showSaveButton(false); item.showCancelButton(false);};"
  html += "} "
  html += "$(document).ready(function(){ ko.applyBindings(new BluePrintViewModel())}); "
  html += "</script></html>"
end

get '/load_blueprints' do
  count = redis.llen "blueprints"
  counter = 0
  jsonArray = []
  while counter < count do
    blueprint = redis.lindex "blueprints", counter
    
    counter=counter+1
    json = JSON.parse redis.get "blueprint___" + blueprint
    jsonArray.push(json)
  end
  status 200
  headers \
    "content-type" => "application/json"
  data =  JSON.generate jsonArray
end

get '/refresh_data' do
  glanceParser = GlanceParser.new
  count = redis.llen "blueprints"
  counter = 0
  jsonArray = []
  while counter < count do
    blueprint = redis.lindex "blueprints", counter
    
    counter=counter+1
    json = JSON.parse redis.get "blueprint___" + blueprint
    jsonArray.push(json)
  end
  status 200
  headers \
    "content-type" => "application/json"
  data =  JSON.generate jsonArray   
end

post '/update_blueprint' do
 request.body.rewind
 data = request.body.read
 new_blueprint = JSON.parse data
 #check the data 
 blueprint = JSON.parse redis.get "blueprint___" + new_blueprint['item']['name']
 if redis.exists "blueprint___" + new_blueprint['item']['name'] then
    existing_blueprint = JSON.parse redis.get "blueprint___" + new_blueprint['item']['name']
    existing_blueprint['design'] = new_blueprint['item']['design']
    existing_blueprint['delivery'] = new_blueprint['item']['delivery']
    existing_blueprint['assignee'] = new_blueprint['item']['assignee']
    existing_blueprint['series'] = new_blueprint['item']['series']
    if new_blueprint['item'].has_key?('comments') then
      existing_blueprint['comments'] = new_blueprint['item']['comments']
    end
    if new_blueprint['item'].has_key?('isracker') then
      existing_blueprint['isracker'] = new_blueprint['item']['isracker']
    end

    redis.set "blueprint___" + new_blueprint['item']['name'], existing_blueprint.to_json
 end
end
