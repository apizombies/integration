require 'net/http'
GITHUB_API_BASE_URL="https://api.github.com:443"

class Github
  def github_delete_api_request (postfix, headers = {})
    url = URI.parse(GITHUB_API_BASE_URL + postfix )
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl= true
    res,data = http.delete(url.path, headers)
  end

  def github_add_api_request (postfix, data, headers = {})
    url = URI.parse(GITHUB_API_BASE_URL + postfix )
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl= true
    res,data = http.put(url.path, data, headers)
	puts res.body
  end

  @auth_token=nil

  def initialize(auth_token)
    @auth_token = auth_token
  end

  def dissasociate_user(organization, username)
    github_delete_api_request("/orgs/#{organization}/memberships/#{username}", {"Authorization" => "token #{@auth_token}"})
  end

  def asociate_user(organization, username, role="admin")
    github_add_api_request("/orgs/#{organization}/memberships/#{username}", "{\"role\": \"#{role}\"}" , {"Authorization" => "token #{@auth_token}"})
  end
end
