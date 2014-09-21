helpers do
  def current_user
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end

  def callback_root
    host_and_port = request.host
    host_and_port << ":9393" if request.host == "localhost"
    return "http://#{host_and_port}"
  end

  def lastfm_auth_url
    host_and_port = request.host
    host_and_port << ":9393" if request.host == "localhost"
    "http://www.last.fm/api/auth/?api_key=#{LASTFM['api_key']}&cb=#{callback_root}/auth/lastfm"
  end

  def soundcloud_client
    SoundCloud.new({
      :client_id     => SOUNDCLOUD['client_id'],
      :client_secret => SOUNDCLOUD['client_secret'],
      :redirect_uri  => "#{callback_root}/auth/soundcloud",
    })
  end

  def soundcloud_auth_url
    client = soundcloud_client
    client.authorize_url(:scope => "non-expiring")
  end
end