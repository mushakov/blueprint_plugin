require 'rubygems'
require 'sinatra'
#require 'slim'
require 'json'
require 'redis'
require 'uri'

redis = Redis.new(:host => '198.61.212.105', :port => 6379)
 
get '/' do
  #slim :index
  status 200
  count = redis.llen "blueprints"
  counter = 0
  html = "<table><thead><tr><th>Blueprint</th><th>Priority</th><th>Delivery</th><th>Series</th><th>Assignee</th><th>Design</th></tr></thead><tbody>"
  while counter < count do
    blueprint = redis.lindex "blueprints", counter
    
    counter=counter+1
    hash_blueprint = JSON.parse redis.get "blueprint___" + blueprint
    priority = (hash_blueprint['priority'] if hash_blueprint.has_key?('priority')).to_s
    delivery = (hash_blueprint['delivery'] if hash_blueprint.has_key?('delivery')).to_s
    series = (hash_blueprint['series'] if hash_blueprint.has_key?('series')).to_s
    assignee = (hash_blueprint['assignee'] if hash_blueprint.has_key?('assignee')).to_s 
    design = (hash_blueprint['design'] if hash_blueprint.has_key?('design')).to_s
    html += "<tr><td>" + hash_blueprint['name'] + "</td>"
    html += "<td>" + priority + "</td>"
    html += "<td>" + delivery + "</td>"
    html += "<td>" + series  + "</td>"
    html += "<td>" + assignee + "</td>"
    html += "<td>" + design + "</td></tr>"
  end
  html += "</tbody></table>"
  #eval(redis.get "blueprints")
end

get '/Question' do
  questionId = 1;
 
  print questionId
  status 200
  content_type :json
  question = eval(redis.get "questions:#{questionId}")
  body question.to_json
end

get '/Question/:answerId' do
  puts params[:answerId]
  questionId = params[:answerId].to_i
  question = eval(redis.get "questions:#{questionId}")
  question[:EncodedQuestion] = URI.escape(question[:Question])
  status 200
  content_type :json
  body question.to_json unless question.empty?
end

put '/Answer/:questionId' do
  # 1. check if the answer is correct for the question
  # 2. get the translation of the text and whether this was a valid response
  # 3. return the next question id, translation and text
  questionId = params[:questionId].to_i
  follow_ups = redis.get "follow_ups:#{questionId}"
  follow_ups = follow_ups.split(',') { |s| s.to_i}
  puts follow_ups
  questionId = follow_ups.sample
  data = JSON.parse request.body.read
  resp = Hash.new
  resp[:Id] = 1
  resp[:Answer] = data['Answer']
  resp[:Translation] = "does not exist yet."
  resp[:Language] = "es"
  resp[:QuestionId] = questionId
  status 200
  content_type :json
end
