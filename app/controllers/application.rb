class Application < Merb::Controller
  def logged_in?
    session[:logged_in] == true
  end

  def app_config
    @config ||= YAML.load_file(File.join(Merb.root, 'config', 'myconfig.yml'))
  end

  def authorize(user, password)
    return user == app_config['user'] && password == app_config['password']
  end

  def admin_required
    unless logged_in?
      throw :halt, proc { |c| c.redirect url(:entries) }
    end
  end
end
