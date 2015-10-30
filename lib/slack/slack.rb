require 'net/http'
require 'json'

SLACK_API_BASE_URL="slack.com:443"

class Slack
  def slack_post_api_request (postfix, data, organization, headers = {})
    url = URI.parse("https://#{organization}." + SLACK_API_BASE_URL + postfix )
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl= true
    res,data = http.post(url.path, data, headers)
  end

  def get_slack_api_request (postfix, data=nil, organization=nil)
	base_url = ""
	if organization
      base_url = "#{organization}.#{SLACK_API_BASE_URL}"
	else
      base_url = "#{SLACK_API_BASE_URL}"
	end
    url = URI.parse("https://#{base_url}#{postfix}" )
  
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl= true

    #res,data = http.get(url.path+ "?" + url.query)
	res,data = http.send_request('GET', "#{url.path}?#{url.query}", data)
    return res.body
  end


  @auth_token=nil

  def initialize(auth_token)
    @auth_token = auth_token
  end

  def get_user_id(token, email)
    json_info = JSON(get_slack_api_request("/api/users.list?token=#{token}"))
    json_info['members'].each do |member|
  	if email==member['profile']['email'] 
        return member['id']
      end
    end
    return nil
  end

  def get_user_name(token, email)
    json_info = JSON(get_slack_api_request("/api/users.list?token=#{token}"))
    json_info['members'].each do |member|
  	if email==member['profile']['email'] 
        return member['name']
      end
    end
    return nil
  end

  def invite_user(organization, mail)
    slack_post_api_request("/api/users.admin.invite", "token=#{@auth_token}&email=#{mail}", organization)
  end

  def disable_user(organization, mail)
    id = get_user_id(@auth_token, mail)
    slack_post_api_request("/api/users.admin.setInactive", "token=#{@auth_token}&user=#{id}&set_active=true", organization)
  end

  def send_message(organization, mail, message, token)
	name = get_user_name(@auth_token, mail)
    get_slack_api_request("/services/hooks/slackbot?token=#{token}&channel=@#{name}", message ,organization)
  end
end
