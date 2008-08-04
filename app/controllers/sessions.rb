class Sessions < Application
  def new
    render
  end

  def create
    if authorize(params[:user], params[:password])
      session[:logged_in] = true
    end
    redirect url(:entries)
  end

  def destroy
    session[:logged_in] = nil
    redirect url(:entries)
  end
end
