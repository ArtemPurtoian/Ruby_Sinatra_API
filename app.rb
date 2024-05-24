require 'sinatra'
require 'json'

get "/api/welcome" do
  content_type :json
  { message: "Hi, this is a simple Sinatra API!" }.to_json
end

not_found do
  content_type :json
  status 404
  { error: "Route not found. Please check your request URL." }.to_json
end
