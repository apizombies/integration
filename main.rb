require 'sinatra'
require 'github/github'
require 'slack/slack'

delete '/slack/:email' do
    email = params[:email]
    slack_token = ENV['slack_token']
    organization = ENV['organization']
	slack = Slack.new(slack_token)
    slack.disable_user(organization, email)
end

put '/slack/:email' do
    email = params[:email]
    slack_token = ENV['slack_token']
    organization = ENV['organization']
	slack = Slack.new(slack_token)
    slack.invite_user(organization, email)
end

delete '/github/:username' do
    username = params[:username]
	github_cred = ENV['github_token']
	organization = ENV['organization']
    github = Github.new(github_cred)
    github.dissasociate_user(organization, username)
end

put '/github/:username' do
    username = params[:username]
	github_cred = ENV['github_token']
	organization = ENV['organization']
    github = Github.new(github_cred)
    github.asociate_user(organization, username)
end
