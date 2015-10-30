require 'google/api_client'
require 'googleapi/auth'

module GoogleAPI
  class Users
    attr_reader :apiclient, :directory_api

    def initialize(apiclient)
      @apiclient = apiclient
      @directory_api = @apiclient.discovered_api('admin', 'directory_v1')
    end

    def users
      @users ||= list
    end

    def get(user_mail_alias_or_id, public_only = false)
      apiclient.execute!(
        api_method: directory_api.users.get,
        parameters: {
          userKey: user_mail_alias_or_id,
          projection: 'full',
          viewType: public_only ? 'domain_public' : 'admin_view',
        }).data
    end

    def make_admin(user_mail_alias_or_id, status = true)
      status = directory_api.users.make_admin.request_schema.new(status: status)
      apiclient.execute!(
        api_method: directory_api.users.make_admin,
        parameters: { userKey: user_mail_alias_or_id },
        body_object: status
      )
    end

    def update(user_mail_alias_or_id, public_only: false, parameters: {})
      user = directory_api.users.update.request_schema.new(parameters)
      apiclient.execute!(
        api_method: directory_api.users.update,
        parameters: { userKey: user_mail_alias_or_id },
        body_object: user
      )
    end

    def insert(primaryemail, pwd, name, last_name, options = {})
      parameters = {
        name: {
          givenName: name,
          familyName: last_name,
          fullName: "#{name} #{last_name}"
        },
        password: pwd,
        primaryEmail: primaryemail,
        changePasswordAtNextLogin: true,
      }.merge(options)
      user = directory_api.users.insert.request_schema.new(parameters)
      apiclient.execute!(
        api_method: directory_api.users.insert,
        body_object: user)
    end

    def delete(user_mail_alias_or_id)
      apiclient.execute!(
        api_method: directory_api.users.delete,
        parameters: { userKey: user_mail_alias_or_id })
    end

    def list(public_only = false)
      @users = apiclient.execute!(
        api_method: directory_api.users.list,
        parameters: {
          orderBy: 'email',
          maxResults: 10,
          customer: 'my_customer',
          #domain: 'apizombies.lol',
          viewType: public_only ? 'domain_public' : 'admin_view',
          projection: 'full',
        }).data.users
    end

    # mimetype can be something like 'image/jpeg', 'image/png', etc
    # photodata should contain the whole data for the type (ie, full JPEG file).
    def set_photo(user_mail_alias_or_id, mimetype, photodata)
      parameters = {
        mimeTytpe: mimetype,
        photoData: self.class.bytes2websafe64(photodata)
      }
      photo = directory_api.users.photos.update.request_schema.new(parameters)
      apiclient.execute!(
        api_method: directory_api.users.photos.update,
        parameters: { userKey: user_mail_alias_or_id },
        body_object: photo)
    end

    # call this to autogenerate a password - be sure to save it!!
    def self.gen_pwd(len = 14)
      o = [('a'..'z'), ('A'..'Z'), ('0'..'9'), ['.', ';', ':', '$', '%', '#', '@', '?', '!', '*']].map { |i| i.to_a }.flatten
      ol = o.length
      len.times.map { o[rand(ol)] }.join
    end

    private

    def self.bytes2websafe64(data)
      require 'base64'
      Base64.encode64(data).tr('/', '_').tr('+', '-').tr('=', '*')
    end
  end
end
