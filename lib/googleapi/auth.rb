require 'googleauth'

module GoogleAPI
  class Auth
    DEFAULT_CREDSFILE = File.expand_path(File.join('..', '..', '..', 'credentials', 'APIZombies_google_admin.json'), __FILE__)
    ADMIN_USER = 'alex@apizombies.lol'.freeze
    SCOPES = ['https://www.googleapis.com/auth/admin.directory.user']

    attr_reader :apiclient, :authorization, :auth_client

    def initialize(credsfile = DEFAULT_CREDSFILE, scopes: SCOPES)
      ENV['GOOGLE_APPLICATION_CREDENTIALS'] = credsfile

      @authorization = Google::Auth.get_application_default(scopes)
      @auth_client = @authorization.dup
      # impersonate admin user
      @auth_client.sub = ADMIN_USER
      # fetch access token
      @auth_client.fetch_access_token!

      @apiclient = Google::APIClient.new(application_name: 'APIZombies User Management')
      @apiclient.authorization = @auth_client
    end
  end
end
