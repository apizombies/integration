require 'net/http'
SLACK_API_BASE_URL="slack.com:443"

class Slack
  def slack_post_api_request (postfix, data, organization, headers = {})
    url = URI.parse("https://#{organization}." + SLACK_API_BASE_URL + postfix )
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl= true
    res,data = http.post(url.path, data, headers)
  end

  def get_slack_api_request (postfix)
    url = URI.parse(SLACK_API_BASE_URL + postfix )
  
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl= true
    
    res,data = http.get(url.path+ "?" + url.query)
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

  def invite_user(organization, mail)
    slack_post_api_request("/api/users.admin.invite", "token=#{@auth_token}&email=#{mail}", organization)
  end

  def disable_user(organization, mail)
    id=get_user_id(@auth_token, mail)
    puts(id)
    disable_user(@auth_token, id)
    slack_post_api_request("/api/users.admin.setInactive", "token=#{token}&user=#{slack_user_id}&set_active=true")
  end
end
