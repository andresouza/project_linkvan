class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery except: :index
  skip_before_action :verify_authenticity_token

private

	def require_signin
		unless current_user
			redirect_to new_session_url, alert: "Please sign in first"
		end
	end

	def current_user
		User.find(session[:user_id]) if session[:user_id]
	end

	helper_method :current_user
end
