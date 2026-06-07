ENV['APP_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'json'
require_relative '../app'

RSpec.describe 'Sinatra API' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  let(:json_response) { JSON.parse(last_response.body) }
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  # TEST WELCOME endpoint
  describe 'Tests for GET /api/welcome endpoint' do
    it 'returns status 200 and the greeting' do
      get '/api/welcome'
      expect(last_response.status).to eq(200)
      expect(json_response['message']).to eq('Hi, this is Sinatra API!')
    end
  end

  # TEST POST /api/users (Create)
  describe 'Tests for POST /api/users endpoint' do
    context 'when data is valid' do
      let(:valid_user) { { user_name: 'Tester', gender: 'male', age: 25 }.to_json }

      it 'successfully creates a user and returns status 201' do
        post '/api/users', valid_user, headers
        expect(last_response.status).to eq(201)
        expect(json_response['message']).to eq("User 'Tester' created successfully.")
      end
    end

    context 'when data is invalid' do
      it "returns status 400 when 'age' is missing" do
        invalid_payload = { user_name: 'NoAge', gender: 'female' }.to_json
        post '/api/users', invalid_payload, headers
        expect(last_response.status).to eq(400)
        expect(json_response['error']).to eq('Missing field: age')
      end

      it "returns status 422 when 'gender' is not String" do
        bad_gender_payload = { user_name: 'User1', gender: 123, age: 20 }.to_json
        post '/api/users', bad_gender_payload, headers
        expect(last_response.status).to eq(422)
        expect(json_response['error']).to eq("'gender' must be a string.")
      end
    end
  end

  # TEST PUT /api/users/:id (Update)
  describe 'Tests for PUT /api/users/:id endpoint' do
    before(:each) do
      # # Creating a user to be updated
      post '/api/users', { user_name: 'OriginalUser', gender: 'male', age: 20 }.to_json, headers
      get '/api/users'
      @user_id = JSON.parse(last_response.body)['users'].last['id']
    end

    context 'when data is valid' do
      it 'successfully updates all fields and returns status 200' do
        update_payload = { user_name: 'UpdatedUser', gender: 'female', age: 21 }.to_json
        put "/api/users/#{@user_id}", update_payload, headers

        current_json = JSON.parse(last_response.body)
        expect(last_response.status).to eq(200)
        expect(current_json['message']).to eq("User with ID '#{@user_id}' updated successfully.")
      end

      it 'allows to update the data leaving the current user_name unchanged' do
        # Updating only gender and age
        same_name_payload = { user_name: 'OriginalUser', gender: 'female', age: 99 }.to_json
        put "/api/users/#{@user_id}", same_name_payload, headers

        expect(last_response.status).to eq(200)
      end
    end

    context 'when data is invalid' do
      it 'returns status 400 if there is a missing field' do
        incomplete_payload = { user_name: 'NewName', gender: 'male' }.to_json # no 'age' field
        put "/api/users/#{@user_id}", incomplete_payload, headers

        current_json = JSON.parse(last_response.body)
        expect(last_response.status).to eq(400)
        expect(current_json['error']).to include('Missing field: age')
      end

      it "returns status 422 if 'age' is not Integer" do
        bad_age_payload = { user_name: 'OriginalUser', gender: 'male', age: 'invalid_age' }.to_json
        put "/api/users/#{@user_id}", bad_age_payload, headers

        current_json = JSON.parse(last_response.body)
        expect(last_response.status).to eq(422)
        expect(current_json['error']).to eq("'age' must be an integer.")
      end

      it 'returns status 409 if new name already exists' do
        # Creating the second user with a unique name
        post '/api/users', { user_name: 'ExistingJack', gender: 'male', age: 30 }.to_json, headers

        # Trying to give the first user (@user_id) the name of the second user ('ExistingJack')
        conflict_payload = { user_name: 'ExistingJack', gender: 'male', age: 25 }.to_json
        put "/api/users/#{@user_id}", conflict_payload, headers

        current_json = JSON.parse(last_response.body)
        expect(last_response.status).to eq(409)
        expect(current_json['error']).to eq("User 'ExistingJack' already exists.")
      end

      it 'returns status 404 if a user with such id is not found ' do
        valid_payload = { user_name: 'NoBody', gender: 'male', age: 25 }.to_json
        put '/api/users/99999', valid_payload, headers

        current_json = JSON.parse(last_response.body)
        expect(last_response.status).to eq(404)
        expect(current_json['error']).to eq('User not found')
      end
    end
  end

  # TEST DELETE /api/users/:id
  describe 'Tests for DELETE /api/users/:id endpoint' do
    context 'when user exists' do
      before do
        # Creating a user before deleting
        post '/api/users', { user_name: 'DeleteMe', gender: 'male', age: 30 }.to_json, headers
        get '/api/users'
        @created_id = JSON.parse(last_response.body)['users'].last['id']
      end

      it 'successfully deletes the user and returns status 200' do
        delete "/api/users/#{@created_id}"

        current_json = JSON.parse(last_response.body)
        expect(last_response.status).to eq(200)
        expect(current_json['message']).to eq("User 'DeleteMe' deleted successfully.")
      end
    end

    context 'when user does not exist' do
      it 'returns status 404 and a readable error' do
        delete '/api/users/9999'

        expect(last_response.status).to eq(404)
        expect(json_response['error']).to eq("User '9999' not found.")
      end
    end
  end

  # TEST ROUTING ERROR HANDLING
  describe 'Tests for global error handler' do
    it "returns status 404 'Route not found' for invalid URL" do
      get '/api/some/completely/wrong/url'

      expect(last_response.status).to eq(404)
      expect(json_response['error']).to eq('Route not found. Please check the URL.')
    end
  end
end