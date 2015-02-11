# encoding: UTF-8

require 'sinatra'
require 'sinatra/json'
require 'mongo'

get '/' do
  redirect to('/index.html')
end

helpers do
  def process
    puts "Method: #{request.request_method}"
    puts "Params: #{request.params}"
    
    mongo_uri = ENV['MONGOLAB_URI']
    db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
    client = Mongo::MongoClient.from_uri(mongo_uri)
    db = client.db(db_name)
    
    api_name = params[:captures].first
    
    outputs = db.collection('outputs')
    output = outputs.find_one({'api_name' => api_name})
    if output == nil then
      return json({})
    else
      if output['status'] != nil then
        status output['status']
      end
      
      if output['file'] != nil then
        return send_file output['file']
      else
        return json(output['data'])
      end
    end
  end
end

get %r{(.+)} do
  process
end

post %r{(.+)} do
  process
end

put %r{(.+)} do
  process
end

delete %r{(.+)} do
  process
end
