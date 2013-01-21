require 'sinatra'
require 'slim'
require 'json'
require 'redis'
require 'uri'

redis = Redis.new(:host => '198.61.212.105', :port => 6379)
 
get '/' do
  slim :index
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
