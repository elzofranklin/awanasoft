class AccountController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  # If you want "remember me" functionality, add this before_filter to Application Controller
  # before_filter :login_from_cookie

  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'softcolors') unless logged_in? || User.count > 0
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if current_user
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/weekly', :action => 'index')
      flash[:notice] = "Logged in successfully"
    else
        @login_failed = true
    end
  end

  def softcolors
    @user = User.new(params[:user])
    return unless request.post?
    @user.save!
    self.current_user = @user
    redirect_back_or_default(:controller => '/account', :action => 'index')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'softcolors'
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/account', :action => 'index')
  end
end
