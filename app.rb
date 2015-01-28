# encoding: UTF-8

require 'sinatra'
require 'sinatra/json'
require 'mongo'

get '/' do
  redirect to('/index.html')
end

def do_with_db
  mongo_uri = ENV['MONGOLAB_URI']
  db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
  client = Mongo::MongoClient.from_uri(mongo_uri)
  db = client.db(db_name)
  yield(db)
end

post '/converter/:api_name' do
  api_name = params[:api_name]
  do_with_db do |db|
    inputs = db.collection('inputs')
    inputs.find_and_modify({
      query: {'api_name' => api_name},
      update: {'api_name' => api_name, 'params' => params},
      new: true,
      upsert: true,
    })
    
    outputs = db.collection('outputs')
    output = outputs.find_one({'api_name' => api_name})
    if output == nil then
      return json({})
    else
      return json(output['data'])
    end
  end
end
