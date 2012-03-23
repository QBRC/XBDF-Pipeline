class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(params[:login], params[:password])
    
    unless user
      user = User.new(:email => params[:login], :password => params[:password])
    end
    
    if user and user.save
      session[:user_id] = user.id
      redirect_to_target_or_default root_url, :notice => 'Logged in successfully.'
    else
      flash.now[:alert] = user.errors.full_messages.to_sentence.downcase
      render :action => 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "You have been logged out."
  end
end
