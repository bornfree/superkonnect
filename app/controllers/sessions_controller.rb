class SessionsController < ApplicationController
  def new
  end

  def create
    auth_hash = request.env['omniauth.auth']

    if session[:user_id]
      # User is already logged in and is either adding a new provider or re-authorizing an older auth
      # whose access keys expired.
      User.find(session[:user_id]).add_provider(auth_hash)
      message = "#{auth_hash["provider"].capitalize} is also connected to your account."
    else
      # New login.
      auth = Authorization.find_or_create(auth_hash)
      session[:user_id] = auth.user.id
      session[:auth_id] = auth.id
      message = "You signed in using #{auth_hash["provider"].capitalize}."
    end
    redirect_to profile_path, :notice => message
    #render :json => auth_hash

  end

  def destroy
    session[:user_id] = nil
    redirect_to :root
  end

  def failure
    render :text => "Bummer. Authorization failure."
  end
end
