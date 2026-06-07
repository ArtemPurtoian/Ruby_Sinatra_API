require 'sinatra'
require 'json'

users = []
user_id_counter = 1

before do
  content_type :json
end

helpers do
  def json_response(object, status = 200)
    halt status, object.to_json
  end

  def is_name_unique?(users, user_name)
    users.all? { |user| user['user_name'] != user_name }
  end

  def get_user_by_id(users, id)
    users.find { |user| user['id'] == id }
  end
end

# --- GET /api/welcome
get "/api/welcome" do
  json_response({ message: "Hi, this is Sinatra API!" })
end

# --- GET /api/greet/:name
get '/api/greet/:name' do
  json_response({ message: "Hello, #{params['name'].capitalize}!" })
end

# --- POST /api/users
post '/api/users' do
  begin
    data = JSON.parse(request.body.read)
  rescue JSON::ParserError
    json_response({ error: 'Invalid JSON' }, 400)
  end
  required = %w[user_name gender age]
  missing = required - data.keys

  if missing.any?
    field_names = missing.join(', ')
    plural = missing.size > 1 ? 'fields' : 'field'
    json_response({ error: "Missing #{plural}: #{field_names}" }, 400)
  end

  unless is_name_unique?(users, data['user_name'])
    json_response({ error: "User '#{data['user_name']}' already exists." }, 409)
  end

  unless data['user_name'].is_a?(String)
    json_response({ error: "'user_name' must be a string." }, 422)
  end

  unless data['gender'].is_a?(String)
    json_response({ error: "'gender' must be a string." }, 422)
  end

  unless data['age'].is_a?(Integer)
    json_response({ error: "'age' must be an integer." }, 422)
  end

  new_user = {
    'id' => user_id_counter,
    'user_name' => data['user_name'],
    'gender' => data['gender'],
    'age' => data['age']
  }

  users << new_user
  user_id_counter += 1
  json_response({
                  message: "User '#{new_user['user_name']}' created successfully.",
                  user: new_user
                }, 201)
end

# --- GET /api/users
get '/api/users' do
  json_response({ users: users })
end

# --- DELETE /api/users/:id
delete '/api/users/:id' do
  user_id = params['id'].to_i
  user = get_user_by_id(users, user_id)

  if user
    users.delete(user)
    json_response({ message: "User '#{user['user_name']}' deleted successfully." }, 200)
  else
    json_response({ error: "User '#{user_id}' not found." }, 404)
  end
end

# --- PUT /api/users/:id
put '/api/users/:id' do
  user_id = params['id'].to_i
  begin
    data = JSON.parse(request.body.read)
  rescue JSON::ParserError
    json_response({ error: 'Invalid JSON' }, 400)
  end
  required = %w[user_name gender age]
  missing = required - data.keys

  if missing.any?
    field_names = missing.join(', ')
    plural = missing.size > 1 ? 'fields' : 'field'
    json_response({ error: "Missing #{plural}: #{field_names}" }, 400)
  end

  unless data['user_name'].is_a?(String)
    json_response({ error: "'user_name' must be a string" }, 422)
  end

  unless data['gender'].is_a?(String)
    json_response({ error: "'gender' must be a string." }, 422)
  end

  unless data['age'].is_a?(Integer)
    json_response({ error: "'age' must be an integer." }, 422)
  end

  user = get_user_by_id(users, user_id)
  if user.nil?
    json_response({ error: "User not found" }, 404)
  end

  if !is_name_unique?(users, data['user_name']) && user['user_name'] != data['user_name']
    json_response({ error: "User '#{data['user_name']}' already exists." }, 409)
  end

  user['user_name'] = data['user_name']
  user['gender'] = data['gender']
  user['age'] = data['age']

  json_response({
                  message: "User with ID '#{user_id}' updated successfully.",
                  user: user
                }, 200)
end

error Sinatra::NotFound do
  content_type :json
  { error: "Route not found. Please check the URL." }.to_json
end
