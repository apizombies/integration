require 'sinatra'
require 'json'
require 'github/github'
require 'slack/slack'
require 'googleapi'

before do
  content_type 'application/json'
  parse_json_params params
end

def parse_json_params(params)
  body = request.body.read
  params.merge! JSON.parse(body, symbolize_names: true) unless body.empty?
end

delete '/slack/:email' do
  email = params[:email]
  slack_token = ENV['slack_token']
  organization = ENV['organization']
  slack = Slack.new(slack_token)
  slack.disable_user(organization, email)
  { status: 'ok' }.to_json
end

put '/slack/:email' do
  email = params[:email]
  slack_token = ENV['slack_token']
  organization = ENV['organization']
  slack = Slack.new(slack_token)
  slack.invite_user(organization, email)
  { status: 'ok' }.to_json
end

delete '/github/:username' do
  username = params[:username]
  github_cred = ENV['github_token']
  organization = ENV['organization']
  github = Github.new(github_cred)
  github.dissasociate_user(organization, username)
  { status: 'ok' }.to_json
end

put '/github/:username' do
  username = params[:username]
  github_cred = ENV['github_token']
  organization = ENV['organization']
  github = Github.new(github_cred)
  github.asociate_user(organization, username)
  { status: 'ok' }.to_json
end

get '/google' do
  google = GoogleAPI::Users.new(GoogleAPI::Auth.new.apiclient)

  users = begin
            google.users
          rescue => e
            halt 400, { error: e.message }.to_json
          end
  { status: 'ok',
    size: users.size,
    users:  users.map do |u|
              {
                name: u.name.givenName,
                last_name: u.name.familyName,
                email: u.primaryEmail
              }
            end,
  }.to_json
end

post '/google/:username' do |username|
  halt 400, { error: 'wrong params' }.to_json unless params[:name] && params[:last_name]
  googleuser = username + '@apizombies.lol'
  password = GoogleAPI::Users.gen_pwd

  google = GoogleAPI::Users.new(GoogleAPI::Auth.new.apiclient)

  begin
    google.get googleuser
  rescue
  else
    halt 400, { error: 'user already exists' }.to_json
  end

  begin
    google.insert googleuser, password, params[:name], params[:last_name]
  rescue => e
    halt 400, { error: e.message }.to_json
  end

  with_photo = false

  # gravatar image
  if params[:email]
    gravatar = GoogleAPI::Users.gravatar_for params[:email]
    if gravatar
      begin
        google.set_photo(googleuser, gravatar)
        with_photo = true
      rescue
      end
    end
  end

  admin = params[:admin] == 'true'
  if admin
    begin
      google.make_admin googleuser
    rescue => e
      halt 400, { error: e.message, email: googleuser, password: password, with_photo: with_photo, admin: false }.to_json
    end
  end

  { status: 'ok', email: googleuser, password: password, with_photo: with_photo, admin: admin }.to_json
end

delete '/google/:username' do |username|
  googleuser = username + '@apizombies.lol'
  google = GoogleAPI::Users.new(GoogleAPI::Auth.new.apiclient)

  begin
    google.get googleuser
  rescue
    halt 404, { error: 'user does not exist' }.to_json
  end

  begin
    google.delete googleuser
  rescue => e
    halt 400, { error: e.message }.to_json
  end
  { status: 'deleted', email: googleuser }.to_json
end
