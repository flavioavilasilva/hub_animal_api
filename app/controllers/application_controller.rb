class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions

  attr_reader :current_user

  rescue_from CanCan::AccessDenied do |exception|
    render_forbidden(exception.message.presence || "Forbidden")
  end

  private

  def authenticate_request!
    token = bearer_token
    return render_unauthorized unless token

    decoded_token = JsonWebToken.decode(token)
    @current_user = User.find(decoded_token[:user_id])
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    render_unauthorized
  end

  def bearer_token
    authorization_header = request.headers["Authorization"]
    return nil unless authorization_header&.start_with?("Bearer ")

    authorization_header.split(" ", 2).last
  end

  def render_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def render_forbidden(message = "Forbidden")
    render json: { error: message }, status: :forbidden
  end
end
